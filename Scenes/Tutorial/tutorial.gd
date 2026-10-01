extends Node2D

@onready var spiele: Array[Control] = [
		$Spiel01,
		$Spiel02,
		$Spiel03,
]

func deactivate_all_games() -> void:
	for spiel in spiele:
		if spiel:
			spiel.visible = false
			spiel.set_process(false)
			spiel.set_physics_process(false)
			if "reset" in spiel:
				spiel.reset()

func skip_to_game_caesar() -> void:
	$Settings/MenuPopup.visible = false
	GameState.skip_explanations = true
	GameState.jump_to_script_index = 1
	GameState.jump_to_text_index = 10
	
	stop_all_sounds(get_tree().get_root())
	hide_all_axolotls()
	deactivate_all_games()
	var spiel01: Control = $Spiel01
	spiel01.visible = true
	spiel01.activate_script()

func skip_to_game_binary() -> void:
	$Settings/MenuPopup.visible = false
	GameState.skip_explanations = true
	GameState.jump_to_script_index = 2
	GameState.jump_to_text_index = 7
	
	stop_all_sounds(get_tree().get_root())
	hide_all_axolotls()
	deactivate_all_games()
	var spiel02: Control = $Spiel02
	spiel02.visible = true
	spiel02.activate_script()

func skip_to_game_shortest_path() -> void:
	$Settings/MenuPopup.visible = false
	GameState.skip_explanations = true
	GameState.jump_to_script_index = 3
	GameState.jump_to_text_index = 6
	
	stop_all_sounds(get_tree().get_root())
	hide_all_axolotls()
	deactivate_all_games()
	var spiel03: Control = $Spiel03
	spiel03.visible = true
	spiel03.activate_script()

func skip_to_game_tree_traversal() -> void:
	$Settings/MenuPopup.visible = false
	GameState.skip_explanations = true
	GameState.jump_to_script_index = 3
	GameState.jump_to_text_index = 13
	
	stop_all_sounds(get_tree().get_root())
	hide_all_axolotls()
	deactivate_all_games()
	var spiel03: Control = $Spiel03
	spiel03.visible = true
	spiel03.activate_script()

func skip_to_game_logic_gates() -> void:	
	TouchController.enable_draggable_nodes(false)
	$Spiel03.circuit.enable_buttons(false)
	$Settings/MenuPopup.visible = false
	GameState.skip_explanations = true
	GameState.jump_to_script_index = 3
	GameState.jump_to_text_index = 22
	
	stop_all_sounds(get_tree().get_root())
	hide_all_axolotls()
	deactivate_all_games()
	var spiel03: Control = $Spiel03
	spiel03.visible = true
	spiel03.activate_script()



func hide_all_axolotls() -> void:
	#if has_node("Funker"):
		$Spiel01/Funker.visible = false
		$Spiel02/Axolotl/Funker.visible = false
		$Spiel03/Axolotl/Funker.visible = false
	#if has_node("Kapitän"):
		$Spiel01/Kapitän.visible = false
		$Spiel02/Axolotl/Kapitän.visible = false
		$Spiel03/Axolotl/Kapitän.visible = false
	#if has_node("Mechaniker"):
		$Spiel01/Mechaniker.visible = false
		$Spiel02/Axolotl/Mechaniker.visible = false
		$Spiel03/Axolotl/Mechaniker.visible = false
	#if has_node("ElderAxolotl"):
		$Spiel01/ElderAxolotl.visible = true
		$Spiel02/Axolotl/ElderAxolotl.visible = true
		$Spiel03/Axolotl/ElderAxolotl.visible = true
	#if has_node("Kanonier"):
		$Spiel02/Axolotl/Kanonier.visible = false
		$Spiel03/Axolotl/Kanonier.visible = false


func _on_ready() -> void:
	if GameState.skip_explanations:
		$Settings/MenuPopup/VBoxContainer/Games.visible = false
	
	%Games.visible = true

func stop_all_sounds(node: Node) -> void:
	for child in node.get_children():
		if child is AudioStreamPlayer or child is AudioStreamPlayer2D or child is AudioStreamPlayer3D:
			if child.playing:
				child.stop()
		elif child.has_method("get_children"):
			stop_all_sounds(child)  # rekursiv in tieferliegende Nodes
