extends Node2D
# ---------- FEEDBACK EXTRA----------
const FEEDBACK_FILE := "res://Components/ElderAxolotl/feedback.json"
var feedback_dict : Dictionary

# ---------- RADIO ----------
@onready var container_radio: Node = $Container_radio
@onready var radios:= [$Container_radio/Radio1/CaesarMinigame, $Container_radio/Radio2/CaesarMinigame, $Container_radio/Radio3/CaesarMinigame]
@onready var led_station_radio:= $Container_radio/LED_Station1
@onready var feedback_radio := [$Feedback/FeedbackOverlay1, $Feedback/FeedbackOverlay4, $Feedback/FeedbackOverlay3]

# ---------- NAVIGATOR ----------
@onready var container_navigator: Node = $Container_navigator
@onready var navigators:= [$Container_navigator/Control1/Navigator1, $Container_navigator/Control2/Navigator2, $Container_navigator/Control3/Navigator3]
@onready var led_station_navigator:= $Container_navigator/LED_Station2
@onready var feedback_navigator := [$Feedback/FeedbackOverlay4, $Feedback/FeedbackOverlay3, $Feedback/FeedbackOverlay2]

var nav_travel_cost : Array[int] = [] # bisher verbrauchte Energie
var nav_visited_nodes : Array = [] # bereits befahrene Knoten

# ---------- SHIP STATUS ----------
@onready var ship_status:= [$Container_navigator/Control1/ShipStatus1, $Container_navigator/Control2/ShipStatus2, $Container_navigator/Control3/ShipStatus3]

# ---------- BINARY ----------
@onready var container_binary: Node = $Container_binary
@onready var binaries := [$Container_binary/Control1/Binary1, $Container_binary/Control2/Binary2, $Container_binary/Control3/Binary3]
@onready var asteroids : Array[Node2D] = [$Asteroid1, $Asteroid2, $Asteroid3]
@onready var led_station_binary:= $Container_binary/LED_Station3
@onready var feedback_binary := [$Feedback/FeedbackOverlay2, $Feedback/FeedbackOverlay1, $Feedback/FeedbackOverlay4]

# ---------- CIRCUIT ----------
@onready var container_circuit: Node = $Container_circuit
@onready var circuits := [$Container_circuit/Circuit1, $Container_circuit/Circuit2, $Container_circuit/Circuit3]
@onready var led_station_circuit:= $Container_circuit/LED_Station4
@onready var feedback_circuit := [$Feedback/FeedbackOverlay3, $Feedback/FeedbackOverlay2, $Feedback/FeedbackOverlay1]

# ---------- CUTSCENES ----------
@onready var cutscenes_radio :Array[Node2D]=[$Cutscenes/Cutscene_coordinates_encrypted]
@onready var cutscenes_navigator :Array[Node2D]=[$Cutscenes/Cutscene_route_found, $Cutscenes/Cutscene_astroid_shower_2]
@onready var cutscenes_binary :Array[Node2D]=[$Cutscenes/Cutscene_astroid_shower,$Cutscenes/Cutscene_system_down]
@onready var cutscenes_circuit :Array[Node2D]=[$Cutscenes/Cutscene_system_repaired, $Cutscenes/Cutscene_planet_reached]

# ---------- WINOVERLAY ----------
@onready var win_overlay: Control = $WinOverlay
@export var current_scene: SceneLoader.GameScene = SceneLoader.GameScene.BONUS

@onready var debug_next_round_button:= $Debug/Button

# ---------- SETUP ----------
const ROUND_SETUPS := {
	1: "_setup_radio_round",
	2: "_setup_cutscene_round_radio",
	3: "_setup_navigator_round",
	4: "_setup_cutscene_round_navigator",
	5: "_setup_binary_round",
	6: "_setup_cutscene_round_binary",
	7: "_setup_circuit_round",
	8: "_setup_cutscene_round_circuit",
	9:"_setup_win_round"
}

var led_station_scene: Control 
var submitted_correct := [false, false, false]
var ready_count := 0
var current_round: int = 1 # startet bei der station

# ---------- SETUP SHIP ENERGIE ----------
var ship_energy_max : int = 50
var ship_energy := [ ship_energy_max, ship_energy_max, ship_energy_max ]

@warning_ignore_start("untyped_declaration")
# ------------------------------------------------------------
# Setup - lots of stuff in comments, will clean up soon
# ------------------------------------------------------------
func _ready() -> void:
	current_round = Vars.bonus_level_next_round
	Vars.bonus_level_next_round = 1 # reset

	_load_feedback()
	clear_astroids()
	_run_round_setup()
	_show_round_ui()

	TouchController.enable_draggable_nodes(true)

# Feedback Laden
func _load_feedback() -> void:
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
	
	
func _show_round_ui() -> void:
	container_radio.visible = (current_round == 1)
	container_navigator.visible = (current_round == 3)
	container_binary.visible = (current_round == 5)
	container_circuit.visible = (current_round == 7)
	
# DO NOT CHANGE - THIS'S SCUFFED 
func _run_round_setup() -> void:
	# Reset allgemeiner Zähler
	ready_count = 0
	submitted_correct = [false, false, false]
	
	if led_station_scene:
		var cb := Callable(self, "_on_next_button_pressed")
		if led_station_scene.is_connected("next_round_pressed", cb):
			led_station_scene.next_round_pressed.disconnect(cb)
	
	if current_round == 1:
		led_station_scene = led_station_radio
		debug_next_round_button.disabled = false
	elif current_round == 3:
		led_station_scene = led_station_navigator
		debug_next_round_button.disabled = false
	elif current_round == 5:
		led_station_scene = led_station_binary
		debug_next_round_button.disabled = false
	elif current_round == 7:
		led_station_scene = led_station_circuit
		debug_next_round_button.disabled = false
	else:
		led_station_scene = null # für Fehlerfälle
		debug_next_round_button.disabled = true
	
	if led_station_scene:
		led_station_scene.reset()
		if not led_station_scene.is_connected("next_round_pressed", Callable(self, "_on_next_button_pressed")):
			led_station_scene.next_round_pressed.connect(Callable(self, "_on_next_button_pressed"))
	
	if ROUND_SETUPS.has(current_round):
		call(ROUND_SETUPS[current_round])
	else:
		push_warning("Kein Setup für Runde %d definiert!" % current_round)
	
# ------------------------------------------------------------
# Next Round Button
# ------------------------------------------------------------
func go_to_next_round() -> void:
	current_round += 1
	_run_round_setup()
	_show_round_ui()
	
func _on_next_button_pressed() -> void:
	go_to_next_round()
	
	
# ------------------------------------------------------------
# Feedback
# ------------------------------------------------------------
func _show_feedback(current_round_id: int, idx: int, success: bool) -> void:
	if feedback_dict.is_empty(): 
		return
	var rkey := str(current_round_id)
	if not feedback_dict.has(rkey):
		return
	var outcome := "success" if success else "fail"
	var lines : Array = feedback_dict[rkey].get(outcome, [])
	if lines.is_empty(): 
		return
	var msg : String = lines.pick_random()
	
	var ov : FeedbackOverlay
	match current_round_id:
		1: ov = feedback_radio[idx]
		2: ov = feedback_navigator[idx]
		3: ov = feedback_binary[idx]
		4: ov = feedback_circuit[idx]
		9: ov = feedback_navigator[idx]
		_: return
		
	ov.show_line(msg)
	
# ------------------------------------------------------------
# Runde 1 - radio
# ------------------------------------------------------------
# Setup radio
func _setup_radio_round() -> void:
	var text_pool := [
	"KOORDINATEN DES HEIMATPLANETEN VERSCHLUESSELT EMPFANGEN ENTZIFFERUNG ERFORDERLICH",
	"VERSCHLUESSELTE KOORDINATENSEQUENZ DES HEIMATSYSTEMS EMPFANGEN BITTE DECHIFFRIEREN",
	"DECHIFFRIERUNG DER HEIMATKOORDINATE NOETIG UEBERMITTELTE DATEN MUESSEN ENTZIFFERT WERDEN"
	]
	led_station_scene.reset()
	
	for i in range(3):
		var radio : Control = radios[i]
		radio.reset()
		radio.set_plain_text(text_pool[i])
		# Erfolg
		var cb := Callable(self, "_on_radio_decrypted_ok").bind(i)
		if not radio.is_connected("decrypted_successfully", cb):
			radio.decrypted_successfully.connect(cb)
		# Fehlversuch
		var cb_fail := Callable(self, "_on_radio_decrypted_fail").bind(i)
		if not radio.is_connected("decrypted_unsuccessfully", cb_fail):
			radio.decrypted_unsuccessfully.connect(cb_fail)
			
func _on_radio_decrypted_ok(index:int) -> void:
	_handle_radio_submission(index, true)
	
func _on_radio_decrypted_fail(index:int) -> void:
	_handle_radio_submission(index, false)
	
func _handle_radio_submission(idx:int, ok:bool) -> void:
	if submitted_correct[idx]:
		return
	if ok:
		submitted_correct[idx] = true
		led_station_scene.set_led_on(idx)
		ready_count += 1
		if ready_count == 3:
			led_station_scene.show_next_round_button()
	_show_feedback(1, idx, ok) 
	
# ------------------------------------------------------------
# Runde 2 - Navigator
# ------------------------------------------------------------
# Setup navigator
func _setup_navigator_round() -> void:
	container_navigator.visible = true
	led_station_scene = led_station_navigator
	led_station_scene.reset()
	
	submitted_correct = [false, false, false]
	ready_count = 0
	
	# jede Station separat initialisieren
	for i in range(navigators.size()):
		var nav: Node2D = navigators[i]
		nav.nav_index = i
		var sbar: Control = ship_status[i]
		
		if not nav.is_connected("navigator_travelled", Callable(self, "_on_nav_travel")):
			nav.navigator_travelled.connect(Callable(self, "_on_nav_travel"))
		if not nav.is_connected("navigator_end_reached", Callable(self, "_on_nav_end")):
			nav.navigator_end_reached.connect(Callable(self, "_on_nav_end"))
		if not nav.is_connected("navigator_invalid_move", Callable(self, "_on_nav_invalid_move")):
			nav.navigator_invalid_move.connect(Callable(self, "_on_nav_invalid_move"))
		
		# Energie volltanken
		ship_energy[i] = ship_energy_max
		_update_ship_status_ui(i)
		
		# Energie voll für diese Station
		ship_energy[i] = ship_energy_max
		sbar.set_energy(ship_energy[i])
		
		# Karte zurücksetzen
		nav.new_round()
		nav.can_travel = true
		
		# Reisekostenzufällig 2-8
		randomize()
		for from in nav.paths.keys():
			for conn in nav.paths[from]:
				conn["cost"] = randi_range(2, 8)
				
		# alte Linien löschen, neue zeichnen
		var pnode = nav.get_node("Paths")
		for c in pnode.get_children():
			c.queue_free()
		nav.create_paths()
		
		if nav_travel_cost.size() < navigators.size():
			nav_travel_cost.resize(navigators.size())
		nav_travel_cost[i] = 0
		
		if nav_visited_nodes.size() < navigators.size():
			nav_visited_nodes.resize(navigators.size())
			nav_visited_nodes[i] = [nav.start_node]
		
		# Signale verbinden
		for j in range(nav.graph_nodes.size()):
			var node : Area2D = nav.graph_nodes[j]
			node.input_pickable = true
			var cb_input = Callable(nav, "_on_grid_node_input").bind(j)
			if not node.is_connected("input_event", cb_input):
				node.connect("input_event", cb_input)
	
func _on_nav_travel(index: int, _target: int, cost: int) -> void:
	# Energie abziehen und UI aktualisieren
	ship_energy[index] = clamp(ship_energy[index] - cost, 0, ship_energy_max)
	_update_ship_status_ui(index)
	
	# Wegkosten sammeln & aktualisieren
	if nav_travel_cost[index] == null:
		nav_travel_cost[index] = 0
	nav_travel_cost[index] += cost
	
	# besuchte Knoten Liste ergänzen und Knoten entsperren
	if nav_visited_nodes[index] == null:
		nav_visited_nodes[index] = []
	nav_visited_nodes[index].append(_target)
	
	# alle Nodes freigeben zum reisen
	call_deferred("_unlock_all_nodes", index)
	
	var reached_goal : bool = _target == navigators[index].end_node
	
	# Feedback wenn Energie = 0
	if ship_energy[index] == 0:
		if reached_goal:
			return
		else:
			_show_feedback(9, index, false)
			call_deferred("_reset_single_navigator", index)
			return
			
	navigators[index].call_deferred("on_round_completed")
	
	
# KNOTEN FREISCHALTEN UM EINBOXEN ZU VERMEIDEN
func _unlock_all_nodes(index:int) -> void:
	var nav = navigators[index]
	
	# Knoten wieder freigeben zum traveln
	for nd in nav.graph_nodes:
		if "deactivated" in nd:
			nd.deactivated = false
		nd.input_pickable = true
		
	# Bereits bereiste Knoten grau markieren (um path zu sehen, beim traveln kann man aber normal auswählen)
	for id in nav_visited_nodes[index]:
		var nd : Area2D = nav.graph_nodes[id]
		if nd.has_method("highlight"):
			nd.highlight(true, nav.color_visited)
		
	
# ENERGIE-BALKEN SYNC
func _update_ship_status_ui(index: int) -> void:
	ship_status[index].set_energy(ship_energy[index])
	
# ABGABE VERARBEITEN
func _process_navigator_submission(index: int) -> void:
	var nav = navigators[index]
	
	# Erfolg nur, wenn gefahrene Kosten exakt optimal sind
	var best_cost : int = nav.shortest_path(nav.start_node, nav.end_node)["cost"]
	var player_cost : int = nav_travel_cost[index]
	var shortest_ok: bool = player_cost == best_cost
	
	if shortest_ok:
		if submitted_correct[index]:
			return
		submitted_correct[index] = true
		led_station_scene.set_led_on(index)
		ready_count += 1
		if ready_count == 3:
			led_station_scene.show_next_round_button()
		_show_feedback(2, index, true) # 2-success
	else:
		_show_feedback(9, index, false) # nicht shortest Path gewählt
		call_deferred("_reset_single_navigator", index) # Neustart
		
	
# ZIEL ERREICHT
func _on_nav_graph_complete() -> void:
	for i in range(3):
		if submitted_correct[i]:
			continue
		var nav = navigators[i]
		if nav.current_node == nav.end_node:
			_process_navigator_submission(i)
	
func _on_nav_end(index: int) -> void:
	if navigators[index].current_node == navigators[index].end_node:
		_process_navigator_submission(index)
	
func _reset_single_navigator(index: int) -> void:
	var nav = navigators[index]
	
	# Spiellogik zurück auf Start
	nav.current_node = nav.start_node
	nav.selected_node = -1
	
	# Shortest Path - Statistik löschen & Tracker reset
	nav_travel_cost[index] = 0
	nav_visited_nodes[index] = [navigators[index].start_node]
	
	# Energie auffüllen, Balken updaten
	ship_energy[index] = ship_energy_max
	_update_ship_status_ui(index)
	
	# LED der Station aus, Zähler zurück
	submitted_correct[index] = false
	
	# -----------------------------------------------
	# ALLE Graph-Nodes wieder freigeben
	# -----------------------------------------------
	for node in nav.graph_nodes:
		if node.has_method("highlight"):
			node.highlight(false) # Farbe zurücksetzen
		if "deactivated" in node:
			node.deactivated = false # Sperre lösen
	# -----------------------------------------------
	
	randomize()
	for from in nav.paths.keys():
		for conn in nav.paths[from]:
			conn["cost"] = randi_range(2, 8)
	
	# alte paths löschen
	var pnode = nav.get_node("Paths")
	if pnode == null:
		pnode = nav.get_node_or_null("Paths")
	if pnode:
		for child in pnode.get_children():
			child.queue_free()
	
	nav.create_paths() # neue paths
	
	# Karte frisch aufbauen
	nav.new_round()
	nav.can_travel = true
	
	
func _on_nav_invalid_move(index:int) -> void:
	_show_feedback(2, index, false)
	
# ------------------------------------------------------------
# Runde 3 - Binary
# ------------------------------------------------------------
# Setup binary
func _setup_binary_round() -> void:
	container_binary.visible = true
	show_astroids()
	for i in range(3):
		binaries[i].set_asteroid(asteroids[i])
		binaries[i].set_my_index(i)
		binaries[i].submitted.connect(_on_binary_submitted)
		
	var rng = RandomNumberGenerator.new()
	
	for i in range(3):
		binaries[i].reset()
		var hp = rng.randi_range(1, 255)
		asteroids[i].set_health(hp)
		binaries[i].set_target_value(hp)
		led_station_scene.reset()
		
# Abgabe Binary & Animation
func _on_binary_submitted(index: int, correct: bool) -> void:
	if submitted_correct[index]:
		return
	
	if correct:
		submitted_correct[index] = true
		
	var ast := asteroids[index]
	ast.explosion_finished.connect(
		func(): _after_explosion(index, correct),CONNECT_ONE_SHOT
		)
	ast.explode()
		
# check nach abgabe, wenn richtig wird LED grün, bei 3 Grün -> neue Runde Button, sonst neuer Gegner
func _after_explosion(index: int, correct: bool) -> void:
	if correct:
		_show_feedback(3, index, correct)
		led_station_scene.set_led_on(index)
		
		ready_count += 1
		if ready_count == 3:
			led_station_scene.show_next_round_button()
			for i in range(asteroids.size()):
				if asteroids[i]:
					asteroids[i].visible = false
	else:
		_show_feedback(3, index, false)
		spawn_new_asteroid(index)
	
	
# Neuer Asteroid an gleicher Position, Zuweisung und neuer Zahl falls Falscheingabe
func spawn_new_asteroid(index: int):
	binaries[index].reset()
	
	var anima : Node2D = asteroids[index]
	
	var hp = RandomNumberGenerator.new().randi_range(1, 116)
	(anima as Node).reset_asteroid(hp)
	
	binaries[index].set_asteroid(anima)
	binaries[index].set_target_value(hp)
	
# nur für testen	
func clear_astroids():
	asteroids[0].visible = false
	asteroids[1].visible = false
	asteroids[2].visible = false
	
func show_astroids():
	asteroids[0].visible = true
	asteroids[1].visible = true
	asteroids[2].visible = true
	
# Target Zahl ändern
func update_input_label(value: int) -> void:
	%InputLabel.text = str(value)
	
# ------------------------------------------------------------
# Runde 4 - Circuit
# ------------------------------------------------------------
# Setup Circuit
func _setup_circuit_round() -> void:
	container_circuit.visible = true
	clear_astroids() # nur während arbeiten, da sonst in round 4 sichtbar
	var expr_pool := ["(values[0] or values[2])", "values[0] or values[1]", "not values[4]"]
	var formatted_expression_pool := ["A ∨ C", "A ∨ B", "¬E"]
	led_station_scene.reset()
	
	for i in range(3):
		var circuit = circuits[i]
		circuit.my_index = i
		circuit.reset()
		circuit.set_expression(expr_pool[i % expr_pool.size()])
		circuit.set_formatted_input_string(formatted_expression_pool[i % formatted_expression_pool.size()])
		var cb := Callable(self, "_on_circuit_submitted")
		if not circuit.is_connected("circuit_evaluated", cb):
			circuit.circuit_evaluated.connect(cb)
			
# Submitting circuits logic
func _on_circuit_submitted(index: int, correct: bool) -> void:
	# print("Circuit", index, "submitted correct:", correct)
	if submitted_correct[index]:
		return
	if correct:
		_show_feedback(4, index, correct)
		submitted_correct[index] = true
		led_station_scene.set_led_on(index)
		ready_count += 1
		if ready_count == 3:
			led_station_scene.show_next_round_button()
	else:
		_show_feedback(4, index, false)
		pass
	
	
# ------------------------------------------------------------
# CUTSCENES
# ------------------------------------------------------------
func _set_game_env_visible(on:bool) -> void:
	for n in [
		$Background,
		$RadarSpace
	]:
		n.visible = on

# Cutscenes setups
func _run_cutscene_sequence(list: Array[Node2D]) -> void:
	#debug_next_round_button.disabled = true
	for scn in list:
		scn.visible = true
		await get_tree().create_timer(2.0).timeout
		scn.visible = false
	_set_game_env_visible(true)
	
func _setup_cutscene_round_radio():
	_set_game_env_visible(false)
	await _run_cutscene_sequence(cutscenes_radio)
	go_to_next_round()
	
func _setup_cutscene_round_navigator():
	_set_game_env_visible(false)
	await _run_cutscene_sequence(cutscenes_navigator)
	go_to_next_round()
	
func _setup_cutscene_round_binary():
	_set_game_env_visible(false)
	await _run_cutscene_sequence(cutscenes_binary)
	go_to_next_round()
	
func _setup_cutscene_round_circuit():
	_set_game_env_visible(false)
	cutscenes_circuit[1].get_node("AnimationPlayer").play("animation")
	await _run_cutscene_sequence(cutscenes_circuit)
	go_to_next_round()
	
func _set_game_invisible(on:bool) -> void:
	for n in [
		$Debug,
		$Einstellung, # da solange win overlay noch nicht funktioniert
		$Background,
		$RadarSpace
	]:
		n.visible = on
		
		
# Funktioniert noch nicht, todo
func _setup_win_round():
	# print("Parent is: ", get_parent())
	print("Setup Win Round")
	_set_game_invisible(false)
	cutscenes_circuit[1].visible = true
	$Cutscenes.layer = -1
	win_overlay.visible = true
	
@warning_ignore_restore("untyped_declaration")


func _on_btn_main_menu_pressed() -> void:
	SceneLoader.load_scene(self, SceneLoader.GameScene.MENU)

func _on_btn_restart_pressed() -> void:
	SceneLoader.load_scene(self, current_scene)

func _on_btn_quit_pressed() -> void:
	get_tree().quit()

func _on_button_round_pressed(extra_arg_0: int) -> void:
	Vars.bonus_level_next_round = extra_arg_0
	SceneLoader.load_scene(self, SceneLoader.GameScene.BONUS)
