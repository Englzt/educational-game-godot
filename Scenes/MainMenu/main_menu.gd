extends Control

@onready var story_toggle_button: CheckButton = %StoryMode

func _ready() -> void:
	story_toggle_button.button_pressed = GameState.skip_explanations
	

func _on_button_mainlevel_pressed() -> void:
	SceneLoader.load_scene(self, SceneLoader.GameScene.MAIN)

func _on_button_exit_pressed() -> void:
	get_tree().quit()

func _on_button_story_pressed() -> void:
	SceneLoader.load_scene(self, SceneLoader.GameScene.CUTSCENE_PROLOGUE_1)

func _on_button_tutorial_pressed() -> void:
	SceneLoader.load_scene(self, SceneLoader.GameScene.TUTORIAL)

func _on_button_bonuslevel_pressed() -> void:
	SceneLoader.load_scene(self, SceneLoader.GameScene.BONUS)

func _on_story_mode_toggled(toggled_on:bool) -> void:
	GameState.skip_explanations = toggled_on

func _on_button_show_licenses_pressed() -> void:
	SceneLoader.load_scene(self, SceneLoader.GameScene.LICENSE_SCREEN)

func _on_button_middle_sequnce_pressed() -> void:
	SceneLoader.load_scene(self, SceneLoader.GameScene.CUTSCENE_PROLOGUE_12)
