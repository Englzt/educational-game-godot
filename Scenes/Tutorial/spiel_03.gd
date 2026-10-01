extends Control

@onready var text_flow := $Text01
@onready var label_template := $Text01/LabelTemplate
@onready var weiter_button := $WeiterTextButton 
@onready var funker := $Axolotl/Funker
@onready var kapitän := $Axolotl/Kapitän
@onready var mechaniker := $Axolotl/Mechaniker
@onready var elderaxolotl := $Axolotl/ElderAxolotl
@onready var kanonier := $Axolotl/Kanonier

@onready var anmerkung := $Anmerkung
@onready var richtig := $Anmerkung/Richtig
@onready var falsch := $Anmerkung/Falsch

@onready var navigator := $Navigator
@onready var zoohandlung := $"BG/Zoohandlung1-01"
@onready var eingang := $BG/Eingang
@onready var treetravel := $TreeTraversal1
@onready var treetravel2 := $TreeTraversal2
@onready var circuit := $Circuit
@onready var donottouch := $Circuit/doNOTtouch
@onready var eingangohnetür := $BG/EingangOhneTuer
@onready var tür := $"BG/Tuer"
@onready var cheatsheet := $CheatSheet

@onready var label_reward1 := $TreeTraversal1/Control/LabelReward
@onready var label_reward2 := $TreeTraversal2/Control/LabelReward

#Sound
@onready var tür_sound := $BG/Tuer_Sound

var current_text_task_id := 0
var skipped_lines: Array[int] = []

var total_navi_cost := 0
var tree1_done := false
var tree2_done := false

var current_task := 0

var dialog_texts := [
	#1
	"Kapitän: „Wir haben es geschafft, wir sind aus dem Becken raus...“",
	#2
	"Kapitän: „Sehen wir zu, dass wir hier endlich verschwinden...“",
	#3
	"Mechaniker: „Schau, da hinten geht es raus...“",
	#4
	"Kapitän: „Gutes Auge, Mechaniker. Aber wie kommen wir dahin?“",
	#5
	"Kapitän: „Ich sehe, dass auf dem Weg nicht nur gekühlte Aquarien liegen, sondern auch Terrarien. Die sollten wir vermeiden, um nicht auszutrocknen...“",
	#6
	"Kapitän: „Gib mir einen Moment, ich überlege uns einen Weg, um hier rauszukommen...“",
	#7
	"Elderaxolotl: „Hallo, meine Freunde, ich bin es wieder, Wächter der Geschichten, Hüter... Ah, ihr kennt den Spaß doch.“",
	#8
	"Elderaxolotl: „Ah, ich sehe, ihr wollt den schnellsten Weg hier rausfinden – den sogenannten Shortest Path...“",
	#9
	"Elderaxolotl: „Um den kürzesten Weg zu finden, benutzt man unter anderem den Dijkstra-Algorithmus, der auch in einem Navi verwendet wird. Dieser probiert alle Wege aus, merkt sich, wie lang ein Weg ist, und kann dann entscheiden, welcher am kürzesten ist.“",
	#10
	"Elderaxolotl: „In unserem Fall wissen wir: Wenn wir an einem Terrarium vorbeikommen, werden wir durch die Wärme verlangsamt. Bei einem gekühlten Aquarium kommen wir schneller voran...“",
	#11
	"Elderaxolotl: „Klickt nun den kürzesten Weg nacheinander an und bestätigt ihn mit dem GO-Button, um schnell von hier zu fliehen. Aber passt auf – manchmal ist der Weg, der am kürzesten scheint, nicht auch der beste, um ans Ziel zu kommen!“",
	#12
	"Kapitän: „Ich hab’s – wir müssen so gehen. Es geht los! Folgt mir!“",
	#13
	"Kapitän: „Nun, nun, was ist das – noch ein Raum! Das ist ja ein reines Labyrinth. Okay, passt auf, wir suchen den Ausgang!“",
	#14
	"Elderaxolotl: „Um die Tür zu finden, sollten wir nicht einfach losstürzen und mit Glück und Chaos den Weg suchen...“",
	#15
	"Elderaxolotl: „Wir können hier eine einfache Tiefensuche durchführen. Dabei geht man so weit wie möglich in eine Richtung, bis es nicht mehr weitergeht, und kehrt dann zur letzten Abzweigung zurück.“",
	#16
	"Elderaxolotl: „Eine andere Möglichkeit ist die Breitensuche – dabei schaust du dir erst alle möglichen Wege an, bevor du tiefer gehst...“",
	#17
	"Elderaxolotl: „Probiere beide Möglichkeiten mal aus!“",
	#18
	"Kapitän: „Da ist die Tür – wir haben sie gefunden...“",
	#19
	"Kapitän: „Sie öffnet sich nicht! Mechaniker!“",
	#20
	"Mechaniker: „Ja, Kapitän?“",
	#21
	"Kapitän: „Schaltungen sind dein Spezialgebiet – versuch, sie zu öffnen.“",
	#22
	"Mechaniker: „Zu Befehl, Kapitän!“",
	#23
	"Elderaxolotl: „Seid gegrüßt, ich bin es wieder! Wie kann ich euch diesmal behilflich sein?“",
	#24
	"Elderaxolotl: „Ah, wie ich sehe, habt ihr eine kleine digitale Schaltung – eine sogenannte Logik-Schaltung, so wie sie auch in echten Computern verwendet wird...“",
	#25
	"Elderaxolotl: „Lasst mich kurz erklären, wie so eine Schaltung funktioniert. Ihr habt verschiedene Eingänge (A bis E), und diese müssen über Bausteine mit dem Ausgang verbunden werden.“",
	#26
	"Elderaxolotl: „Wenn Strom fließt, bezeichnet man das als 'wahr' (true). Wenn kein Strom fließt, ist das 'falsch' (false). Die Bausteine zwischen den Eingängen heißen Logik-Gatter. Mit ihnen könnt ihr aus mehreren Eingängen einen bestimmten Ausgang erzeugen.“",
	#27
	"Elderaxolotl: „Wir haben hier 4 verschiedene Gatter. Das erste ist AND (UND): Nur wenn beide Eingänge wahr sind, ist auch der Ausgang wahr.“",
	#28
	"Elderaxolotl: „Dann gibt es OR (ODER): Hier reicht es, wenn mindestens einer der Eingänge wahr ist – dann ist der Ausgang auch wahr.“",
	#29
	"Elderaxolotl: Als Nächstes kommt XOR (Entweder-Oder): Der Ausgang ist nur dann wahr, wenn genau einer der beiden Eingänge wahr ist.“",
	#30
	"Elderaxolotl: „Und schließlich das NOT-Gatter (NICHT): Es dreht den Eingang um – aus wahr wird falsch, und aus falsch wird wahr.“",
	#31
	"Elderaxolotl: „Eure Aufgabe ist es, mit diesen Gattern die Eingänge so zu verbinden, dass die Schaltung genau das tut, was in der Aufgabenbeschreibung steht.“",
	#32
	"Elderaxolotl: „Wenn ihr denkt, dass alles richtig verbunden ist, klickt auf 'EVALUATE', um die Schaltung zu prüfen. Viel Erfolg, Schaltungsmeister!“",
	#33
	"Kapitän: „Sehr gut, die Tür öffnet sich. Endlich können wir diesen Ort verlassen...“",
]

var current_text_index := 0
var text_fertig := false
var button_wurde_deaktiviert := false

func _ready() -> void:
	randomize()
	
	set_process(false)
	set_physics_process(false)
	get_parent().get_node("Spiel03").visible = false
	
	navigator.visible = false
	treetravel.visible = false
	treetravel2.visible = false
	kapitän.visible = true
	mechaniker.visible = false
	elderaxolotl.visible = false
	funker.visible = false
	kanonier.visible = false
	circuit.visible = false
	eingangohnetür.visible = false
	tür.visible = false
	cheatsheet.visible = false
	
	float_actor(kapitän)
	float_actor(funker)
	float_actor(mechaniker)
	float_actor(elderaxolotl)
	float_actor(kanonier)
	
	$Anmerkung.visible = false
	$Anmerkung/Richtig.visible = false
	$Anmerkung/Falsch.visible = false
	
	$Navigator/Control/ButtonTravel.pressed.connect(_on_button_travel_pressed_from_main)
	navigator.navigator_end_reached.connect(_on_navigator_end_reached)
	navigator.navigator_travelled.connect(_on_navigator_travelled)

	update_navigator_path_cost(0, 1, 5)   # YES (0→1)
	# update_navigator_path_cost(0, 2, 20)  # NO  (0→2 missing)
	# update_navigator_path_cost(0, 3, 25)  # NO  (0→3 missing)
	update_navigator_path_cost(1, 2, 4)   # YES (1→2)	
	update_navigator_path_cost(1, 3, 15)  # YES (2→3)
	# update_navigator_path_cost(1, 4, 18)  # NO  (1→4 missing)
	update_navigator_path_cost(2, 3, 6)  # YES (2→3)
	# update_navigator_path_cost(2, 5, 3)   # NO  (2→5 missing)
	# update_navigator_path_cost(3, 6, 20)  # NO  (3→6 missing)
	update_navigator_path_cost(4, 5, 4)   # YES (4→5)
	update_navigator_path_cost(4, 7, 9)   # YES (4→7)
	update_navigator_path_cost(5, 6, 10)  # YES (5→6)
	# update_navigator_path_cost(5, 7, 12)  # NO  (5→7 missing)
	update_navigator_path_cost(5, 8, 25)  # YES (5→8)
	update_navigator_path_cost(6, 8, 30)  # YES (6→8)
	update_navigator_path_cost(7, 8, 22)  # YES (7→8)
	# update_navigator_path_cost(7, 9, 5)   # NO  (7→9 missing)
	update_navigator_path_cost(8, 9, 6)   # YES (8→9)
	update_navigator_path_cost(7, 10, 24)

	prints(navigator.shortest_path(navigator.start_node, navigator.end_node))

	$TreeTraversal1.tree_traversed_local.connect(_on_tree1_finished)
	$TreeTraversal2.tree_traversed_local.connect(_on_tree2_finished)

	$TreeTraversal1/Control/VBoxContainer.visible = true
	$TreeTraversal1/Control/LabelReward.visible = false
	$TreeTraversal2/Control/LabelReward.visible = false
	
	if GameState.skip_explanations:
		set_skipped_lines([6, 7, 8, 9, 10, 13, 14, 15, 22, 23, 24, 25, 26, 27, 28, 29, 30])
	
	weiter_button.pressed.connect(on_weiter_text_button_pressed)
	await get_tree().create_timer(1.0).timeout
	await show_next_text()
	
	circuit.circuit_evaluated.connect(_on_circuit_evaluated)
	circuit.enable_buttons(false)
	TouchController.enable_draggable_nodes(false)

func activate_script() -> void:
	set_process(true)
	set_physics_process(true)
	AudioManager.create_2d_audio_at_location(Vector2(200,400), SoundEffect.SOUND_EFFECT_TYPE.CRICKET)
	
	if GameState.jump_to_text_index >= 0:
		current_text_index = GameState.jump_to_text_index
		GameState.jump_to_text_index = -1
		print("Sprung Spiel3")

		# Alle Effekte bis zur Sprung-Zeile simulieren
		#for i in range(current_text_index):
			#await play_effect_for_line(i)

	if current_text_index < dialog_texts.size():
		await show_next_text()

func deactivate_script() -> void:
	set_process(false)
	set_physics_process(false)

#Blendet Node ein
func fade_in(node: Node, duration: float = 0.5) -> void:
	if node == richtig:
		zeige_richtig_text()
	elif node == falsch:
		zeige_falsch_text()
		
	await get_tree().create_timer(1.5).timeout
	node.visible = true
	node.modulate.a = 0.0  
	var tween := get_tree().create_tween()
	tween.tween_property(node, "modulate:a", 1.0, duration)

#Blednet Node aus
func fade_out(node: Node, duration: float = 0.5) -> void:
	var tween := get_tree().create_tween()
	tween.tween_property(node, "modulate:a", 0.0, duration)
	await tween.finished
	node.visible = false 

#Schweben (leichte Beweegung) der Node
func float_actor(actor: Node) -> void:
	var tween := get_tree().create_tween()
	tween.set_loops()  # unendlich oft wiederholen
	tween.bind_node(actor)
	tween.tween_property(actor, "position:y", actor.position.y - 30, 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(actor, "position:y", actor.position.y, 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

#Weiter Button des Dialog Textes mit führt folge Action aus (sichtbarkeit)
func on_weiter_text_button_pressed() -> void:
	anmerkung.visible = false
	await play_effect_for_line(current_text_index)
	await show_next_text()

#Zeigt Dialog schritt Weise Wort für Wort an
func show_text_gradually(text: String, char_delay: float) -> void:
	current_text_task_id += 1
	var this_task := current_text_task_id

	# Flow leeren (außer Template)
	for child in text_flow.get_children():
		if child != label_template:
			child.queue_free()

	var words := text.split(" ")
	for word in words:
		var word_label := label_template.duplicate()
		word_label.visible = true
		word_label.text = ""
		text_flow.add_child(word_label)

		if word_label == null:
					continue
		for c in word:
			if this_task != current_text_task_id:
				return 
			 # Abbrechen, weil neue Aufgabe gestartet wurde
			word_label.text += c
			await get_tree().create_timer(char_delay).timeout

		if word_label == null:
				continue
		
		word_label.text += " "
		await get_tree().create_timer(char_delay).timeout

	if this_task == current_text_task_id:
		text_fertig = true
		if button_wurde_deaktiviert:
			weiter_button.disabled = false

#Zeigt den nächsten Satz im Dialog an
func show_next_text() -> void:
	text_fertig = false

	# Merken, ob Button deaktiviert wurde
	if not weiter_button.disabled:
		weiter_button.disabled = true
		button_wurde_deaktiviert = true
	else:
		button_wurde_deaktiviert = false

	while current_text_index < dialog_texts.size():
		await play_effect_for_line(current_text_index)

		if current_text_index in skipped_lines:
			current_text_index += 1
			continue

		var text: String = dialog_texts[current_text_index]
		current_text_index += 1
		await show_text_gradually(text, 0.00)
		return


	print("Dialog beendet oder alle Zeilen übersprungen.")
	
func _on_button_travel_pressed_from_main() -> void:
	#print("ButtonTravel im Main-Skript gedrückt")
	SignalBus.round_completed.emit()

func _on_navigator_end_reached(nav_index: int) -> void:
	print(" Tatsächliche Reisekosten:", total_navi_cost)
	if total_navi_cost == navigator.shortest_path(navigator.start_node, navigator.end_node)["cost"]:
		print(" Ziel erreicht! Navigator Index:", nav_index)
		fade_in(anmerkung)
		fade_in(richtig)
		weiter_button.disabled = false
		await get_tree().create_timer(3.0).timeout
		fade_out(anmerkung)
		fade_out(richtig)
	else:
		reset_navigator_game()
		fade_in(anmerkung)
		fade_in(falsch)
		await get_tree().create_timer(3.0).timeout
		fade_out(anmerkung)
		fade_out(falsch)

func update_navigator_path_cost(from: int, to: int, new_cost: int) -> void:
	# 1. Pfadwerte ändern
	for connection: Dictionary in navigator.paths.get(from, []):
		if connection["to"] == to:
			connection["cost"] = new_cost
	for connection: Dictionary in navigator.paths.get(to, []):
		if connection["to"] == from:
			connection["cost"] = new_cost

	# 2. Bestehende Linien und Labels entfernen
	var paths_node := navigator.get_node("Paths")
	for child in paths_node.get_children():
		child.queue_free()

	# 3. Neu aufbauen
	navigator.create_paths()

func _on_navigator_travelled(_nav_index: int, _target_node: int, cost: int) -> void:
	total_navi_cost += cost
	#print("🧾 Reisekosten gesamt:", total_navi_cost)

	SignalBus.round_completed.emit()

func reset_navigator_game() -> void:
	# 1. Reisekosten zurücksetzen
	total_navi_cost = 0

	# 2. Navigator-Zustände zurücksetzen
	navigator.current_node = navigator.start_node
	navigator.selected_node = -1
	navigator.can_travel = false

	# 3. Pfadlinien entfernen
	var paths_node := navigator.get_node("Paths")
	for child in paths_node.get_children():
		child.queue_free()

	# 4. Alle Knoten zurücksetzen (außer Startpunkt)
	for i: int in navigator.graph_nodes.size():
		var node: Node = navigator.graph_nodes[i]
		node.highlight(false)
		node.deactivated = false

	# 5. Startpunkt farbig machen
	var start_node: Node = navigator.graph_nodes[navigator.start_node]
	start_node.highlight(true, navigator.color_current)

	# 6. Neue Pfade und Runde starten
	navigator.create_paths()
	navigator.new_round()

func _on_tree1_finished(success: bool) -> void:
	if success:
		tree1_done = true
		label_reward1.visible = false
		label_reward2.visible = false
		fade_in(anmerkung)
		fade_in(richtig)
		await get_tree().create_timer(6.0).timeout
		fade_out(anmerkung)
		fade_out(richtig)
	else:
		label_reward2.visible = false
		label_reward1.visible = false
		$TreeTraversal1.reset()
		$TreeTraversal1.set_traversal_mode(0)
		$TreeTraversal1.show_traversal_mode_string()
		$TreeTraversal1/Nodes/TreeNode0.set_modulate(Color("#64ff64"))
		fade_in(anmerkung)
		fade_in(falsch)
		await get_tree().create_timer(6.0).timeout
		fade_out(anmerkung)
		fade_out(falsch)
	check_tree_traversals_complete()

func _on_tree2_finished(success: bool) -> void:
	if success:
		tree2_done = true
		label_reward2.visible = false
		label_reward1.visible = false
		fade_in(anmerkung)
		fade_in(richtig)
		await get_tree().create_timer(6.0).timeout
		fade_out(anmerkung)
		fade_out(richtig)
	else:
		label_reward2.visible = false
		label_reward1.visible = false
		$TreeTraversal2.reset()
		$TreeTraversal2.set_traversal_mode(1)
		$TreeTraversal2.show_traversal_mode_string()
		$TreeTraversal2/Nodes/TreeNode0.set_modulate(Color("#64ff64"))
		fade_in(anmerkung)
		fade_in(falsch)
		await get_tree().create_timer(6.0).timeout
		fade_out(anmerkung)
		fade_out(falsch)
	check_tree_traversals_complete()

func check_tree_traversals_complete() -> void:
	if tree1_done and tree2_done:
		weiter_button.disabled = false

func task_1() -> void:
	circuit.reset()
	circuit.visible = true
	circuit.set_formatted_input_string("A ∧ B")
	circuit.set_expression("values[0] and values[1]")  # A and B

func task_2() -> void:
	circuit.reset()
	circuit.visible = true
	circuit.set_formatted_input_string("C ∨ ¬D")
	circuit.set_expression("values[2] or !values[3]")  # C or not D

func task_3() -> void:
	circuit.reset()
	circuit.visible = true
	circuit.set_formatted_input_string("A ⊕ E")
	circuit.set_expression("values[0] != values[4]")  # A xor E

func task_4() -> void:
	circuit.reset()
	circuit.visible = true
	circuit.set_formatted_input_string("(A ∧ B) ∨ ((C ⊕ D) ∧ ¬E)")
	circuit.set_expression("(values[0] and values[1]) or ((values[2] != values[3]) and !values[4])")

func load_task(index: int) -> void:
	match index:
		0: task_1()
		1: task_2()
		2: task_3()
		3: task_4()

func next_task() -> void:
	current_task += 1
	load_task(current_task)
	
func _on_circuit_evaluated(_index: int, correct: bool) -> void:
	if correct:
		if current_task == 3:  #3
				weiter_button.disabled = false
		else:
			fade_in(anmerkung)
			fade_in(richtig)
			await get_tree().create_timer(1.5).timeout
			current_task += 1
			load_task(current_task)
			await get_tree().create_timer(1.5).timeout
			fade_out(anmerkung)
			fade_out(richtig)
	else:
		fade_in(anmerkung)
		fade_in(falsch)
		await get_tree().create_timer(3).timeout
		fade_out(anmerkung)
		fade_out(falsch)

func set_skipped_lines(lines: Array[int]) -> void:
	skipped_lines = lines

func play_effect_for_line(index: int) -> void:
	match index:
		2:
			kapitän.visible = false
			mechaniker.visible = true
		3:
			kapitän.visible = true
			mechaniker.visible = false
		5:
			fade_in(navigator)
		6:
			weiter_button.disabled = false
			kapitän.visible = false
			elderaxolotl.visible = true
			navigator.visible = true
		10:
			SignalBus.round_completed.emit()
			weiter_button.disabled = true
		11:
			kapitän.visible = true
			elderaxolotl.visible = false
			weiter_button.disabled = false
		12:
			fade_out(navigator)
			fade_out(zoohandlung)
			fade_out(self)
			await get_tree().create_timer(1.0).timeout
			fade_in(eingang)
			fade_in(self)
			await get_tree().create_timer(1.5).timeout
			eingang.position = Vector2(2361.126, 1272.896)
			eingang.scale =  Vector2(1.719, 1.156)
		13:
			zoohandlung.visible = false
			eingang.visible = true
			eingang.position = Vector2(2361.126, 1272.896)
			eingang.scale =  Vector2(1.719, 1.156)
			weiter_button.disabled = false
			kapitän.visible = false
			elderaxolotl.visible = true
			treetravel.reset()
			treetravel.set_traversal_mode(0)
			treetravel.show_traversal_mode_string()
			treetravel2.reset()
			treetravel2.set_traversal_mode(1)
			treetravel2.show_traversal_mode_string()
			fade_in(treetravel)
			await fade_in(treetravel2)
		16:
			weiter_button.disabled = true
		17:
			var tween := create_tween()
			tween.parallel().tween_property(eingang, "position", Vector2(2004.051, 1083.396), 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
			tween.parallel().tween_property(eingang, "scale", Vector2(1.47, 0.989), 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

			kapitän.visible = true
			elderaxolotl.visible = false
			await fade_out(treetravel)
			await fade_out(treetravel2)
		19:
			kapitän.visible = false
			mechaniker.visible = true
			weiter_button.disabled = false
		20:
			kapitän.visible = true
			mechaniker.visible = false
			task_1()
			fade_in(circuit)
			fade_in(cheatsheet)
		21:
			kapitän.visible = false
			mechaniker.visible = true
		22:
			eingang.visible = true
			zoohandlung.visible = false
			weiter_button.disabled = false
			kapitän.visible = false
			elderaxolotl.visible = true
			mechaniker.visible = false
			task_1()
			circuit.visible = true
			cheatsheet.visible = true
		31:
			donottouch.visible = false
			weiter_button.disabled = true
			TouchController.enable_draggable_nodes(true)
			circuit.enable_buttons(true)
		32:

			fade_out(cheatsheet)
			await fade_out(circuit)
			elderaxolotl.visible = false
			kapitän.visible = true
			eingangohnetür.visible = true
			tür.visible = true
			var tween_tür := create_tween()
			tween_tür.parallel().tween_property(tür, "position", Vector2(3886.341, 1077.0), 3.0).set_trans(Tween.TRANS_SINE) #.set_ease(Tween.EASE_IN_OUT)
			tween_tür.parallel().tween_property(tür, "scale", Vector2(0.005, 0.989), 3.0).set_trans(Tween.TRANS_SINE) #.set_ease(Tween.EASE_IN_OUT)
			if not tür_sound.playing:
				tür_sound.play()
		33:
			fade_out($Axolotl)
			fade_out($TextHG)
			fade_out(weiter_button)
			fade_out($Text01)
			var tween := create_tween()
			tween.parallel().tween_property(eingangohnetür, "position", Vector2(-9927.0, -882.0), 3.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
			tween.parallel().tween_property(eingangohnetür, "scale", Vector2(11.066, 5.568), 3.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
			fade_out(tür)
			await tween.finished
			await get_tree().create_timer(1.0).timeout
			SceneLoader.load_scene(self.get_parent(), SceneLoader.GameScene.MAIN)

var richtig_text_varianten := [
	"Sehr gut gemacht!",
	"Das war korrekt!",
	"Richtig – weiter so!",
	"Gute Arbeit!"
	]

var falsch_text_varianten := [
	"Das stimmt leider nicht!",
	"Versuch's nochmal!",
	"Das war leider falsch!",
	"Nicht ganz richtig!"
]
func zeige_richtig_text() -> void:
	falsch.visible = false
	var text: String = richtig_text_varianten[randi() % richtig_text_varianten.size()]
	richtig.text = text
	richtig.visible = true

func zeige_falsch_text() -> void:
	richtig.visible = false
	var text: String = falsch_text_varianten[randi() % falsch_text_varianten.size()]
	falsch.text = text
	falsch.visible = true

func reset() -> void:
	# Allgemeines zurücksetzen
	set_process(false)
	set_physics_process(false)
	current_text_index = 0
	text_fertig = false
	current_text_task_id = 0
	skipped_lines.clear()
	current_task = 0
	tree1_done = false
	tree2_done = false
	total_navi_cost = 0

	# Sichtbarkeiten zurücksetzen
	kapitän.visible = true
	mechaniker.visible = false
	elderaxolotl.visible = false
	funker.visible = false
	kanonier.visible = false
	navigator.visible = false
	treetravel.visible = false
	treetravel2.visible = false
	circuit.visible = false
	anmerkung.visible = false
	richtig.visible = false
	falsch.visible = false
	donottouch.visible = false
	eingang.visible = false
	zoohandlung.visible = true

	# Rewards ausblenden
	label_reward1.visible = false
	label_reward2.visible = false

	# Weiter-Button
	weiter_button.disabled = true

	# Graphen & Circuit & Trees zurücksetzen
	if is_instance_valid(navigator):
		reset_navigator_game()
	if is_instance_valid(circuit):
		circuit.reset()
	if is_instance_valid(treetravel):
		treetravel.reset()
	if is_instance_valid(treetravel2):
		treetravel2.reset()

	# Pfade & Traversal-Modi
	if is_instance_valid(treetravel):
		treetravel.set_traversal_mode(0)
		treetravel.show_traversal_mode_string()
	if is_instance_valid(treetravel2):
		treetravel2.set_traversal_mode(1)
		treetravel2.show_traversal_mode_string()

	# Text-Flow leeren
	for child in text_flow.get_children():
		if child != label_template:
			child.queue_free()
