extends Node

enum GameScene {
	MENU,
	TUTORIAL,
	MAIN,
	BONUS,
	LICENSE_SCREEN,
	CUTSCENE_PROLOGUE_1,
	CUTSCENE_PROLOGUE_2,
	CUTSCENE_PROLOGUE_3,
	CUTSCENE_PROLOGUE_4,
	CUTSCENE_PROLOGUE_5,
	CUTSCENE_PROLOGUE_6,
	CUTSCENE_PROLOGUE_7,
	CUTSCENE_PROLOGUE_8,
	CUTSCENE_PROLOGUE_9,
	CUTSCENE_PROLOGUE_10,
	CUTSCENE_PROLOGUE_11,
	CUTSCENE_PROLOGUE_12,
	CUTSCENE_PROLOGUE_13,
	CUTSCENE_PROLOGUE_14
}

const GameScenePath: Dictionary = {
	GameScene.MENU: "res://Scenes/MainMenu/main_menu.tscn",
	GameScene.TUTORIAL: "res://Scenes/Tutorial/tutorial.tscn",
	GameScene.MAIN: "res://Scenes/MainLevel/main_level.tscn",
	GameScene.BONUS: "res://Scenes/BonusLevel/bonus_level.tscn",
	GameScene.LICENSE_SCREEN: "res://Scenes/LicenseOverview/license_overview.tscn",
	GameScene.CUTSCENE_PROLOGUE_1: "res://Scenes/Cutscenes/prologue_1.tscn",
	GameScene.CUTSCENE_PROLOGUE_2: "res://Scenes/Cutscenes/prologue_2.tscn",
	GameScene.CUTSCENE_PROLOGUE_3: "res://Scenes/Cutscenes/prologue_3.tscn",
	GameScene.CUTSCENE_PROLOGUE_4: "res://Scenes/Cutscenes/prologue_4.tscn",
	GameScene.CUTSCENE_PROLOGUE_5: "res://Scenes/Cutscenes/prologue_5.tscn",
	GameScene.CUTSCENE_PROLOGUE_6: "res://Scenes/Cutscenes/prologue_6.tscn",
	GameScene.CUTSCENE_PROLOGUE_7: "res://Scenes/Cutscenes/prologue_7.tscn",
	GameScene.CUTSCENE_PROLOGUE_8: "res://Scenes/Cutscenes/prologue_8.tscn",
	GameScene.CUTSCENE_PROLOGUE_9: "res://Scenes/Cutscenes/prologue_9.tscn",
	GameScene.CUTSCENE_PROLOGUE_10: "res://Scenes/Cutscenes/prologue_10.tscn",
	GameScene.CUTSCENE_PROLOGUE_11: "res://Scenes/Cutscenes/prologue_11.tscn",	
	GameScene.CUTSCENE_PROLOGUE_12: "res://Scenes/Cutscenes/prologue_12.tscn",
	GameScene.CUTSCENE_PROLOGUE_13: "res://Scenes/Cutscenes/prologue_13.tscn",
	GameScene.CUTSCENE_PROLOGUE_14: "res://Scenes/Cutscenes/prologue_14.tscn"
}

var loading_screen: PackedScene = preload("res://Scenes/LoadingScreen/loading_screen.tscn")

func load_scene(current_scene: Node, next_scene: GameScene) -> void:
	# create a new loading screen instance
	var loading_screen_instance: Node = loading_screen.instantiate()
	get_tree().get_root().call_deferred("add_child", loading_screen_instance)
	
	# Find path to scene file in GAME_SCENES	
	var load_path: String
	if GameScenePath.has(next_scene):
		load_path = GameScenePath[next_scene]
	else:
		load_path = GameScenePath[GameScene.MAIN]
	
	var loader_next_scene: int
	if ResourceLoader.exists(load_path):
		loader_next_scene = ResourceLoader.load_threaded_request(load_path)
	
	if loader_next_scene == null:
		print("Error: Attempting to load non-existing file!")
		return
		
	await loading_screen_instance.safe_to_load
	current_scene.queue_free()
	
	while true:
		var load_progress: Array = []
		var load_status: int = ResourceLoader.load_threaded_get_status(load_path, load_progress)
		
		match load_status:
			#ResourceLoader.THREAD_LOAD_INVALID_RESOURCE
			0:
				print("Error: Cannot load - Resource invalid.")
				return
			#ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			1:
				loading_screen_instance.get_node("Control/VBoxContainer/ProgressBar").set_value(load_progress[0] * 100)
				#print("loading: ", load_progress)
			#ResourceLoader.THREAD_LOAD_FAILED:
			2:
				print("Error: Loading failed!")
				return
			#ResourceLoader.THREAD_LOAD_LOADED:
			3:
				#print("loading done")
				var next_scene_instance: Node = ResourceLoader.load_threaded_get(load_path).instantiate()
				get_tree().get_root().call_deferred("add_child", next_scene_instance)
				loading_screen_instance.queue_free()
				return
