extends Node2D

@onready var circuit: Node2D = %Circuit
@onready var navigator: Node2D = %Navigator
@onready var ship_status: Control = %ShipStatus
@onready var radar: Node2D = %Radar
@onready var binary: Node2D = %Binary
@onready var caesar: Control = %CaesarMinigame
@onready var round_progress: Control = %RoundProgress
@onready var tree_traversal: Node2D = %TreeTraversal
@onready var binary_minigame: Control = %BinaryMinigame

@onready var feedback_overlays: Array[Control] = [
	%FeedbackRadio,
	%FeedbackBinary,
	%FeedbackCircuit,
	%FeedbackTree
]

@onready var radio_inc_led: Sprite2D = %RadioIncLED

@onready var debug_panel: Control = %DEBUG

@onready var game_intro_screen: Control = %GameIntroScreen
@onready var start_game_button: Button = %ButtonStartGame

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var game_over_screen: Control = %GameOverScreen
@onready var game_over_label: Label = %GameOverLabel

@onready var debug_monster_health_label: Label = %LabelMonsterHealth
@onready var debug_monster_health_binary_label: Label = %LabelMonsterHealthBinary
@onready var debug_tree_mode_label: Label = %LabelTreeMode
@onready var debug_radio_key_label: Label = %LabelRadioKey
@onready var debug_shortest_path_label: Label = %LabelShortestPath
@onready var debug_shortest_path_cost_label: Label = %LabelShortestPathCost

@export var monsters: Array[MonsterStat] = []

var ship_health: int = 50
var ship_energy: int = 50

var is_last_round: bool = false

var radio_messages_counter: int = 0

const FEEDBACK_FILE := "res://Components/ElderAxolotl/feedback.json"
var feedback_dict : Dictionary

# Stations: Funker, Kanonier, Kapitän, Mechaniker
var stations_ready: Dictionary = {
	"Radio": false,
	"Gunner": false,
	"Captain": false,
	"Mechanic": false
}

## Engine configurations
# factors : Array
# expression : String (for the validation)
# expression_UI : String (for the UI)
# target_system : String (for the UI)
var engine_configurations: Array = []

func _ready() -> void:

	self.load_feedback()

	for station: Control in feedback_overlays:
		station.visible = false

	self.reset_round()
	self.enable_all_stations(false)
	game_intro_screen.visible = true

	self.load_engine_configurations()

	SignalBus.circuit_evaluated.connect(self.on_circuit_evaluated)
	SignalBus.binary_submitted.connect(self.on_binary_submitted)
	SignalBus.monster_defeated.connect(self.on_monster_defeated)
	SignalBus.code_decrypted.connect(self.on_code_decrypted)
	SignalBus.round_started.connect(self.start_round)
	SignalBus.tree_traversed.connect(self.on_tree_traversed.bind(true))
	SignalBus.graph_node_travelled.connect(self.on_graph_node_travelled)
	SignalBus.graph_node_end_reached.connect(self.on_graph_node_end_reached)
	SignalBus.round_completed.connect(self.on_round_completed)
	SignalBus.ship_damaged.connect(self.on_ship_damaged)
	ship_status.on_energy_depleted.connect(self.game_over)
	caesar.cooldown_started.connect(self.show_feedback.bind(0))

	binary_minigame.game_finished.connect(self.on_tree_traversed.bind(false)) # using on_tree_traversed since both do the same

	navigator.randomize_path_costs()
	ship_energy = navigator.shortest_path(0, 9)["cost"]
	ship_status.set_initial_energy(ship_energy + 5)

func start_round() -> void:
	# reset all stations
	self.reset_round()

	# spawn a random monster
	var current_monster: MonsterStat = monsters.pick_random()
	var monster_health: int = current_monster.set_random_health()
	radar.spawn_monster(current_monster)

	debug_monster_health_label.text = str(monster_health)
	debug_monster_health_binary_label.text = String.num_int64(monster_health, 2)

	debug_shortest_path_label.text = JSON.stringify(navigator.shortest_path(0, 9)["path"])
	debug_shortest_path_cost_label.text = str(navigator.shortest_path(0, 9)["cost"])

	# generate a random radio message with the monster's health and pass it to the caesar minigame
	var radio_key: int = caesar.set_plain_text(RadioTools.get_health_radio_transmission(monster_health))
	debug_radio_key_label.text = str(radio_key)
	self.blink_radio_led()

	# set tree traversal mode
	var traversal_mode: int = randi() % 2
	tree_traversal.pick_random_layout()
	tree_traversal.set_traversal_mode(traversal_mode)

	var debug_tree_mode_str: String = "Breadth-First Search"
	if traversal_mode == 1:
		debug_tree_mode_str = "Depth-First Search"
	debug_tree_mode_label.text = debug_tree_mode_str

	# set the engine config
	var engine_config: Dictionary = engine_configurations.pick_random()
	ship_status.set_status_effects(engine_config.get("factors"))
	ship_status.set_config_expression(engine_config.get("expression_UI"))
	ship_status.set_target_system(engine_config.get("target_system"))
	circuit.set_expression(engine_config.get("expression"))

func reset_round() -> void:
	for station: String in stations_ready.keys():
		stations_ready[station] = false
	
	radar.reset()
	binary.reset()
	caesar.reset()
	circuit.reset()
	ship_status.reset()
	round_progress.reset()
	tree_traversal.reset()
	binary_minigame.reset()

	radio_messages_counter = 0

func load_engine_configurations() -> void:
	var file: FileAccess = FileAccess.open("res://Scenes/MainLevel/environment_factors.json", FileAccess.READ)
	if file:
		var json: JSON = JSON.new()
		var err: int = json.parse(file.get_as_text())
		if err == OK:
			engine_configurations = json.get_data()
			# prints("Engine configurations loaded: ", engine_configurations)
			# prints("----------")
			# prints(engine_configurations[0]["factors"][0])
		else:
			print("Error parsing JSON: ", json.get_error_message())
		file.close()
	else:
		print("Error opening file")

func on_circuit_evaluated(circuit_correct: bool) -> void:
	stations_ready["Mechanic"] = circuit_correct
	if !circuit_correct:
		self.show_feedback(2)

func on_binary_submitted(decimal_value: int) -> void:
	if radar.current_monster.stats == null:
		return
	if radar.current_monster.stats.health != decimal_value:
		self.show_feedback(1)
		return

	radar.shoot(decimal_value)

func on_monster_defeated() -> void:
	stations_ready["Gunner"] = true

func on_code_decrypted(_code: String) -> void:
	radio_messages_counter += 1

	if radio_messages_counter == 1:
		if radar.current_monster.stats == null:
			return
		binary.set_target_value(radar.current_monster.stats.health)

		await get_tree().create_timer(15).timeout # wait 15 seconds before sending the next radio message

		var radio_key: int = caesar.set_plain_text(RadioTools.get_tree_traversal_radio_transmission(tree_traversal.traversal_mode))
		debug_radio_key_label.text = str(radio_key)
		self.blink_radio_led()

	if radio_messages_counter == 2:
		tree_traversal.show_traversal_mode_string()

func on_tree_traversed(solved: bool, is_tree_traversal: bool) -> void:
	var health_delta: int = Vars.MINIGAME_HEALTH_AMOUNT
	if solved:		
		health_delta = -Vars.MINIGAME_HEALTH_AMOUNT # success adds 5 health, but since on_ship_damaged subtracts health, - (-5) = +5
		ship_energy += Vars.MINIGAME_ENERGY_AMOUNT
	else:
		ship_energy -= Vars.MINIGAME_ENERGY_AMOUNT
		if is_tree_traversal:
			self.show_feedback(3)

	self.on_ship_damaged(health_delta)

	ship_energy = clamp(ship_energy, 0, 50)
	ship_status.set_energy(ship_energy)

func on_graph_node_travelled(_node_index: int, cost: int) -> void:
	ship_energy -= cost
	ship_status.set_energy(ship_energy)
	self.start_round()

func on_graph_node_end_reached() -> void:
	is_last_round = true

func enable_all_stations(enable: bool) -> void:
	# disable all stations to prevent further interaction
	navigator.set_process_input(enable)
	circuit.set_process_input(enable)
	circuit.set_process(enable)
	circuit.set_physics_process(enable)
	binary.set_process_input(enable)
	binary.set_physics_process(enable)
	binary.set_process(enable)
	caesar.set_process_input(enable)
	tree_traversal.set_process_input(enable)
	radar.set_process(enable)
	
	if enable:
		radar.process_mode = Node.PROCESS_MODE_ALWAYS
	else:
		radar.process_mode = Node.PROCESS_MODE_DISABLED

	SignalBus.enable_draggable_nodes.emit(enable)

func on_round_completed() -> void:
	if not is_last_round:
		return

	self.enable_all_stations(false)

	game_over_screen.visible = true
	
	game_over_label.text = "Mission erfolgreich abgeschlossen!"
	animation_player.play("game_over")

func on_ship_damaged(damage: int) -> void:
	ship_health -= damage
	ship_health = clamp(ship_health, 0, 50)
	ship_status.set_health(ship_health)

	if ship_health <= 0:
		self.game_over()
		return

func game_over() -> void:
	self.enable_all_stations(false)
	game_over_screen.visible = true
	game_over_label.text = "Mission gescheitert!"
	animation_player.play("game_over")

func blink_radio_led() -> void:

	await get_tree().create_timer(1.0).timeout
	
	var color_off: Vector4 = radio_inc_led.material.get_shader_parameter("color_off")
	var color_on: Vector4 = radio_inc_led.material.get_shader_parameter("color_on")
	var time: float = 1.0
	var blink_count: int = 4

	var tween: Tween = get_tree().create_tween()
	for i: int in blink_count:
		tween.tween_property(radio_inc_led, "material:shader_parameter/color_off", color_on, time)
		tween.tween_property(radio_inc_led, "material:shader_parameter/color_off", color_off, time)

	await tween.finished

func load_feedback() -> void:
	var f := FileAccess.open(FEEDBACK_FILE, FileAccess.READ)
	if not f:
		push_error("Feedback-Datei fehlt!")
		feedback_dict = {}
		return
	var j := JSON.new()
	if j.parse(f.get_as_text()) != OK:
		push_error("JSON-Fehler in feedback.json")
		feedback_dict = {}
		return
	feedback_dict = j.get_data()

func show_feedback(station: int) -> void:
	var key: int = 0

	match station:
		0: key = 5
		1: key = 6
		2: key = 7
		3: key = 8

	if feedback_dict.is_empty(): 
		prints("Feedback dictionary is empty, cannot show feedback.")
		return
	if not feedback_dict.has(str(key)):
		prints("Feedback key ", key, " not found in dictionary.")
		return
	var lines: Array = feedback_dict[str(key)].get("fail", [])
	if lines.is_empty(): 
		return
	var msg : String = lines.pick_random()

	var ov: Control = feedback_overlays[station]	
	ov.visible = true
	ov.show_line(msg)

########### DEBUG PANEL ###########

func _on_debug_kill_monster_pressed() -> void:
	SignalBus.monster_defeated.emit()

func _on_debug_end_round_pressed() -> void:
	self.start_round()

func _on_debug_monster_attack_pressed() -> void:
	radar._on_monster_timer_timeout()

func _on_button_spawn_monster_pressed() -> void:
	var current_monster: MonsterStat = monsters.pick_random()
	var monster_health: int = current_monster.set_random_health()
	debug_monster_health_label.text = str(monster_health)
	radar.spawn_monster(current_monster)

func _on_button_solve_circuit_pressed() -> void:
	SignalBus.circuit_evaluated.emit(true)

func _on_button_solve_tree_pressed() -> void:
	SignalBus.tree_traversed.emit(true)

func _on_button_continue_pressed() -> void:
	SceneLoader.load_scene(self, SceneLoader.GameScene.BONUS)

func _on_button_start_game_pressed() -> void:
	start_game_button.disabled = true

	game_intro_screen.visible = false
	game_intro_screen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	game_intro_screen.z_index = -1

	self.enable_all_stations(true)
	self.start_round()

func _on_button_main_menu_pressed() -> void:
	SceneLoader.load_scene(self, SceneLoader.GameScene.MENU)

func _on_button_restart_pressed() -> void:
	SceneLoader.load_scene(self, SceneLoader.GameScene.MAIN)
