extends Button

@onready var games_list: VBoxContainer = %GamesContainer
@onready var button_caesar: Button = %GameCaesar
@onready var button_binary: Button = %GameBinary
@onready var button_shortest_path: Button = %GameShortestPath
@onready var button_tree_traversal: Button = %GameTreeTraversal
@onready var button_logic_gates: Button = %GameLogicGates

func _ready() -> void:
	self.pressed.connect(_on_pressed)

func _on_game_caesar_pressed() -> void:
	get_owner().skip_to_game_caesar()
	games_list.visible = false

func _on_game_binary_pressed() -> void:
	get_owner().skip_to_game_binary()
	games_list.visible = false

func _on_game_shortest_path_pressed() -> void:
	get_owner().skip_to_game_shortest_path()
	games_list.visible = false

func _on_game_tree_traversal_pressed() -> void:
	get_owner().skip_to_game_tree_traversal()
	games_list.visible = false

func _on_game_logic_gates_pressed() -> void:
	get_owner().skip_to_game_logic_gates()
	games_list.visible = false

func _on_pressed() -> void:
	games_list.visible = not games_list.visible
