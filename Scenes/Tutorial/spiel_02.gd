extends Control

@onready var binary1 := $Binary
@onready var binary2 := $Binary2

@onready var text_flow := $Text01
@onready var label_template := $Text01/LabelTemplate
@onready var weiter_button := $WeiterTextButton 
@onready var funker := $Axolotl/Funker
@onready var kapitän := $Axolotl/Kapitän
@onready var mechaniker := $Axolotl/Mechaniker
@onready var elderaxolotl := $Axolotl/ElderAxolotl
@onready var kanonier := $Axolotl/Kanonier

@onready var sub_viewport := $Projektion/SubViewport_Binary1
@onready var viewport_display := $Projektion/ViewportDisplay_Binary1

@onready var sub_viewport2 := $Projektion/SubViewport_Binary2
@onready var viewport_display2 := $Projektion/ViewportDisplay_Binary2

@onready var anmerkung := $Anmerkung
@onready var richtig := $Anmerkung/Richtig
@onready var falsch := $Anmerkung/Falsch

@onready var Anzeige1 := $Anzeige
@onready var schrank := $BG/ZoohandlungSchrank

#Sound
@onready var grillen_sound := $BG/Nacht_Sound
var current_text_task_id := 0
var skipped_lines: Array[int] = []
#Binary1
var binary_copy: Node = null
var binary2_copy: Node = null
var time_accumulator := 0.0

var dialog_texts := [
	#1
	"Kapitän: „Es ist so weit, wir sind alleine. Los geht's...“",
	#2
	"Techniker: „Wir erwarten deine Befehle, Kapitän!“",
	#3
	"Kapitän: „Als Erstes müssen wir dieses Glashaus irgendwie aufbekommen.“",
	#4
	"Funker: „Wir haben vorhin doch eine Nachricht empfangen, die besagt, dass der Deckel aufgeht, wenn das Wasser zu warm ist.“",
	#5
	"Kapitän: „Gut aufgepasst! Sucht nach einer Einstellmöglichkeit für die Temperatur!“",
	#6
	"Techniker: „Ich hab hier etwas – das sieht so aus, als ob man damit was einstellen könnte.“",
	#7
	"Elderaxolotl: „Hallo, meine Freunde, ich bin es wieder, Wächter der Geschichten, Hüter des Wissens.“",
	#8
	"Elderaxolotl: „Es sieht so aus, als ob du eine Binärschaltung vor dir hast. Du kennst bestimmt schon das Dezimalsystem – das besteht aus den Zahlen von 0 bis 9...“",
	#9
	"Elderaxolotl: „Das Binärsystem, oder auch Dualsystem, besteht nur aus zwei Zahlen: der 0 und der 1. Damit können Computer besser rechnen – 1 ist, wenn der Strom an ist, und 0, wenn der Strom aus ist...“",
	#10
	"Elderaxolotl: „Um mithilfe des Binärsystems größere Zahlen darzustellen, hat jeder Hebel einen bestimmten Wert. Von rechts mit 1 beginnend, wird der Wert immer verdoppelt – also 1, 2, 4, 8, 16, 32, 64, 128...“",
	#11
	"Elderaxolotl: „Um unsere gesuchte Zahl zu erhalten, aktivieren wir die entsprechenden Hebel, die in der Summe auf die gewünschte Zahl kommen...“",
	#12
	"Techniker: „Kapitän, schau! Der Deckel geht auf.“",
	#13
	"Kapitän: „Gut gemacht! Nun müssen wir die Bewegungsmelder ausschalten. Dafür müssen wir den dreistelligen Code eingeben!“",
	#14
	"Techniker: „Wird gemacht, Kapitän!“",
	#15
	"Techniker: „Alles erledigt!“",
	#16
	"Kapitän: „Hervorragende Arbeit!“",
]
var current_text_index := 0
var text_fertig := false
var button_wurde_deaktiviert := false
#Start
func _ready() -> void:

	randomize()
	set_process(false)
	set_physics_process(false)
	get_parent().get_node("Spiel02").visible = false
	
	$Binary.visible = false
	$Binary2.visible = false
	$Anzeige.visible = false
	
	$Anmerkung.visible = false
	$Anmerkung/Richtig.visible = false
	$Anmerkung/Falsch.visible = false
	
	$Binary.value_correct.connect(_on_correct)
	$Binary.value_wrong.connect(_on_wrong)
	$Binary2.value_correct.connect(_on_correct)
	$Binary2.value_wrong.connect(_on_wrong)
	
	
	
	float_actor(kapitän)
	float_actor(funker)
	float_actor(mechaniker)
	float_actor(elderaxolotl)
	float_actor(kanonier)
	
	funker.visible = false
	mechaniker.visible = false
	elderaxolotl.visible = false
	kanonier.visible = true
	kapitän.visible = false
	
	schrank.visible = false
	$Projektion/ViewportDisplay_Binary1.visible = false
	$Projektion/ViewportDisplay_Binary2.visible = false
	
	binary1.visible = true
	binary1.z_index = -100
	
	binary2.visible = true
	binary2.z_index = -100
	
	anmerkung.z_index = 101
	
	binary_copy = binary1.duplicate(15)
	sub_viewport.add_child(binary_copy)
	_update_binary_copy()
	viewport_display.texture = sub_viewport.get_texture()

	binary2_copy = binary2.duplicate(15)
	sub_viewport2.add_child(binary2_copy)
	_update_binary2_copy()
	viewport_display2.texture = sub_viewport2.get_texture()




	if GameState.skip_explanations:
		set_skipped_lines([6, 7, 8, 9, 10])
	
	
	weiter_button.pressed.connect(on_weiter_text_button_pressed)
	await get_tree().create_timer(6.0).timeout
	await show_next_text()
	
	
	
	#await transition_to_scene03()
#Skript an schalten
func activate_script() -> void:
	set_process(true)
	set_physics_process(true)
	AudioManager.create_2d_audio_at_location(Vector2(200,400), SoundEffect.SOUND_EFFECT_TYPE.CRICKET)
	elderaxolotl.visible = false

	if GameState.jump_to_text_index >= 0:
		current_text_index = GameState.jump_to_text_index
		GameState.jump_to_text_index = -1
		print("Sprung Spiel2")

		# Alle Effekte bis zur Sprung-Zeile simulieren
		#for i in range(current_text_index):
			#await play_effect_for_line(i)

	if current_text_index < dialog_texts.size():
		await show_next_text()
#Skript aus schalten
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
				return  # Abbrechen, weil neue Aufgabe gestartet wurde
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
#Aufgabe erfüllt
func _on_correct() -> void:
	#$Binary/Control/VBoxContainer/Control/ButtonFire.disabled = true
	$WeiterTextButton.disabled = false
	print(" Der eingegebene Wert war korrekt!")
	$Binary/Panel.visible = false
	# if $Binary2/Panel != null:
	# 	$Binary2/Panel.visible = false
	fade_in(anmerkung)
	fade_in(richtig)
	await get_tree().create_timer(6.0).timeout
	fade_out(anmerkung)
	fade_out(richtig)
#Aufgabe nicht erfüllt
func _on_wrong() -> void:
	print(" Der eingegebene Wert war falsch.")
	fade_in(anmerkung)
	fade_in(falsch)
	await get_tree().create_timer(6.0).timeout
	fade_out(anmerkung)
	fade_out(falsch)
#transition to next Game
func transition_to_scene03() -> void:
	var spiel02 := self
	var spiel03 := get_parent().get_node("Spiel03")

	# Spiel02 vorbereiten (unsichtbar aber aktiv)
	spiel03.visible = true
	spiel03.modulate.a = 0.0  # Start transparent

	# Spiel01 ausfaden
	await fade_out(spiel02, 2.0)
	spiel02.visible = false
	
	await get_tree().create_timer(1.0).timeout
	# Spiel02 einfaden
	await fade_in(spiel03, 3.0)
	spiel03.activate_script()

	# Dieses Script deaktivieren
	set_process(false)
	set_physics_process(false)
	$WeiterTextButton.disabled = true
#überspringen von Zeilen Storymode
func set_skipped_lines(lines: Array[int]) -> void:
	skipped_lines = lines
#Effekte
func play_effect_for_line(index: int) -> void:
	match index:
		1:
			kapitän.visible = false
			kanonier.visible = true
		2:
			kapitän.visible = true
			kanonier.visible = false
		3:
			kapitän.visible = false
			funker.visible = true
		4:
			kapitän.visible = true
			funker.visible = false
		5:
			schrank.visible = true
			$Projektion/ViewportDisplay_Binary1.visible = true
			
			kapitän.visible = false
			kanonier.visible = true
			binary1.z_index = 100
			Anzeige1.visible = true
		6:
			elderaxolotl.visible = true
			kanonier.visible = false
		7:
			$Projektion/ViewportDisplay_Binary1.visible = true
			schrank.visible = true
			elderaxolotl.visible = true
			weiter_button.disabled = false
			if $BG/AquariumDeckel.visible == false:
				fade_in($BG/AquariumDeckel)
			binary1.reset()
			binary2.reset()
			binary2.z_index = -100
			binary1.set_target_value(21)
			binary1.z_index = 100
			Anzeige1.visible = true
		10:
			$Binary/Panel.visible = false
			$WeiterTextButton.disabled = true
		11:
			elderaxolotl.visible = false
			kapitän.visible = false
			kanonier.visible = true
			await fade_out($BG/AquariumDeckel)
		12:
			kapitän.visible = true
			kanonier.visible = false
		13:
			$Projektion/ViewportDisplay_Binary2.visible = true
			binary2.set_target_value(196)
			kapitän.visible = false
			kanonier.visible = true
			binary2.z_index = 100
			# if $Binary2/Panel != null:
			# 	$Binary2/Panel.visible = false
			$WeiterTextButton.disabled = true
		15:
			kapitän.visible = true
			kanonier.visible = false
		16:
			await transition_to_scene03()
#Text Richtig
var richtig_text_varianten := [
	"Sehr gut gemacht!",
	"Das war korrekt!",
	"Richtig – weiter so!",
	"Gute Arbeit!"
	]
#Text Falsch
var falsch_text_varianten := [
	"Das stimmt leider nicht!",
	"Versuch's nochmal!",
	"Das war leider falsch!",
	"Nicht ganz richtig!"
	]
#Sichtbarkeit und random Richtig
func zeige_richtig_text() -> void:
	falsch.visible = false
	var text: String = richtig_text_varianten[randi() % richtig_text_varianten.size()]
	richtig.text = text
	richtig.visible = true
#Sichtbarkeit und random Falsch
func zeige_falsch_text() -> void:
	richtig.visible = false
	var text: String = falsch_text_varianten[randi() % falsch_text_varianten.size()]
	falsch.text = text
	falsch.visible = true

func _update_binary_copy() -> void:
	# Alte Kopie entfernen, falls vorhanden
	if binary_copy and binary_copy.is_inside_tree():
		binary_copy.queue_free()

	# Neue Kopie erstellen
	binary_copy = binary1.duplicate()
	sub_viewport.add_child(binary_copy)

func _update_binary2_copy() -> void:
	# Alte Kopie entfernen, falls vorhanden
	if binary2_copy and binary2_copy.is_inside_tree():
		binary2_copy.queue_free()

	# Neue Kopie erstellen
	binary2_copy = binary2.duplicate()
	sub_viewport2.add_child(binary2_copy)

func _process(delta: float) -> void:
	time_accumulator += delta
	if time_accumulator >= 0.1:
		time_accumulator = 0.0
		_update_binary_copy()
		_update_binary2_copy()
