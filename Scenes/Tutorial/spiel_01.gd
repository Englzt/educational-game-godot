extends Control

@onready var text_flow := $Text01
@onready var label_template := $Text01/LabelTemplate
@onready var weiter_button := $WeiterTextButton 
@onready var funker := $Funker
@onready var kapitän := $Kapitän
@onready var mechaniker := $Mechaniker
@onready var elderaxolotl := $ElderAxolotl
@onready var radiostation := $BG/RadioStation
@onready var hintergrundsound := $BG/HintergrundSound
@onready var cheatsheet := $CheatSheet

#Caesar Spiel 1
@onready var caesarminigame := $CaesarMinigame
@onready var encryptetText := $CaesarMinigame/EncryptedText
@onready var histogram := $CaesarMinigame/HistogramContainer
@onready var applybutton := $CaesarMinigame/ApplyButton
@onready var rad_sprite := $CaesarMinigame/rad_sprite
@onready var spinbox := $CaesarMinigame/SpinBox
@onready var fixedEncryptedtext := $CaesarMinigame/FixedEncryptedText
@onready var shift_label := $CaesarMinigame/ShiftLabel
@onready var shift_up_button := $CaesarMinigame/ShiftUpButton
@onready var shift_down_button := $CaesarMinigame/ShiftDownButton
@onready var sprite2D := $CaesarMinigame/rad_sprite
@onready var histogramHG := $HistogramHG

#Caesar Spiel 2
@onready var caesarminigame2 := $ZweiCaesarMinigame2
@onready var encryptetText2 := $ZweiCaesarMinigame2/EncryptedText
@onready var histogram2 := $ZweiCaesarMinigame2/HistogramContainer
@onready var applybutton2 := $ZweiCaesarMinigame2/ApplyButton
@onready var rad_sprite2 := $ZweiCaesarMinigame2/rad_sprite
@onready var spinbox2 := $ZweiCaesarMinigame2/SpinBox
@onready var fixedEncryptedtext2 := $ZweiCaesarMinigame2/FixedEncryptedText
@onready var shift_label2 := $ZweiCaesarMinigame2/ShiftLabel
@onready var shift_up_button2 := $ZweiCaesarMinigame2/ShiftUpButton
@onready var shift_down_button2 := $ZweiCaesarMinigame2/ShiftDownButton
@onready var sprite2D2 := $ZweiCaesarMinigame2/rad_sprite

@onready var anmerkung := $Anmerkung
@onready var richtig := $Anmerkung/Richtig
@onready var falsch := $Anmerkung/Falsch

var current_text_task_id := 0
var skipped_lines: Array[int] = []
var button_wurde_deaktiviert := false


# Text 
var dialog_texts := [
	#1
	"Kapitän: „Meine Freunde, hört mir zu. Zu lange schon leben wir hinter diesem Glas – als Schaustück, als Kuriosität im Becken. Doch damit ist jetzt Schluss...“",
	#2
	"Kapitän: „Ich kann die Gesichter nicht mehr ertragen, die sich gegen die Scheibe pressen. Das ständige Klopfen, das grelle Licht der Kameras... Ich halte es nicht mehr aus...“",
	#3
	"Kapitän: „Wir haben genug beobachtet, genug gelernt. Es ist Zeit, heimzukehren...“",
	#4
	"Mechaniker: „Aber Kapitän... wie sollen wir hier nur entkommen?“",
	#5
	"Kapitän: „Ich habe einen Plan. Der erste Schritt: Wir müssen herausfinden, wann der beste Moment zur Flucht ist...“",
	#6
	"Kapitän: „Funker!“",
	#7
	"Funker: „Ja, Kapitän?“",
	#8
	"Kapitän: „Stell deine Antennen auf Empfang. Hol uns Informationen.“",
	#9
	"Funker: „Aye aye, Kapitän...“",
	#10
	"Funker: „Ich habe etwas gefunden, Kapitän! Aber es ist... seltsam. Nur Buchstaben – sie ergeben keinen Sinn... Moment... Das ist verschlüsselt! Ich erkenne das... Gebt mir einen Augenblick.“",
	#11
	"Elderaxolotl: „Seid gegrüßt, meine Freunde. Ich bin der Wächter der Geschichten und Hüter des Wissens. Ich werde euch bei eurer Aufgabe unterstützen...“",
	#12
	"Elderaxolotl: „Der Text, den ihr gefunden habt, ist mit einer Caesar-Verschlüsselung kodiert...“",
	#13
	"Elderaxolotl: „Diese Methode stammt von Gaius Julius Caesar. Er verschob die Buchstaben im Alphabet um eine feste Anzahl, damit nur Eingeweihte seine Botschaften lesen konnten...“",
	#14
	"Elderaxolotl: „Ein einfaches Beispiel: Aus A wird D, wenn man jeden Buchstaben drei Stellen nach vorne rückt...“",
	#15
	"Elderaxolotl: „Das Problem ist: Wir kennen den Schlüssel nicht. Ihr müsst ihn herausfinden, um die Botschaft zu entschlüsseln...“",
	#16
	"Elderaxolotl: „Dafür gibt es Tricks: Achtet auf kurze Wörter – drei Buchstaben könnten 'die', 'der' oder 'das' sein...“",
	#17
	"Elderaxolotl: „Und nutzt moderne Hilfsmittel: Ein Histogramm kann euch zeigen, welche Buchstaben am häufigsten vorkommen. Im Deutschen sind das meist E, N und I...“",
	#18
	"Elderaxolotl: „Nun denn – stellt mit dem Regler oder mit den Knöpfen den richtigen Schlüssel ein... und entschlüsselt die Botschaft. Viel Erfolg!“",
	#19
	"Funker: „Huch, das ist aber interessant.“",
	#20
	"Kapitän: „Gute Arbeit! Am besten merken wir sie uns – vielleicht können wir sie später noch gebrauchen. Schau weiter, ob du vielleicht noch herausfindest, wann der Laden schließt.“",
	#21
	"Funker: „Ich hab hier noch was – vielleicht hilft uns das weiter...“",
	#22
	"Kapitän: „Gut gemacht. Jetzt wissen wir, wann wir fliehen werden. Macht euch bereit – heute Abend werden wir von hier entkommen.“",
]
var current_text_index := 0
var text_fertig := false

#wird beim Start aufgerufen, initialisiert Suchtbarkeit und Verbindungen
func _ready() -> void:
	#Sound
	hintergrundsound.play()
	randomize()
	histogramHG.visible = false
	$CaesarMinigame.visible = true
	$CaesarMinigame/FixedEncryptedText.visible = false
	$CaesarMinigame/SpinBox.visible = false
	$CaesarMinigame/EncryptedText.visible = false
	$CaesarMinigame/ApplyButton.visible = false
	$CaesarMinigame/rad_sprite.visible = true
	$CaesarMinigame/HistogramContainer.visible = false
	$CaesarMinigame/DecryptedText.visible = false
	$CaesarMinigame/ShiftDownButton.visible = false
	$CaesarMinigame/ShiftLabel.visible = false
	$CaesarMinigame/ShiftUpButton.visible = false
	$CaesarMinigame/rad_sprite.visible = false
	cheatsheet.visible = false

	$ZweiCaesarMinigame2.visible = false
	radiostation.visible = false
	#Synchronisieren von Caesar 1 und 2
	sync_position_and_size(caesarminigame, caesarminigame2)
	sync_position_and_size(fixedEncryptedtext, fixedEncryptedtext2)
	sync_position_and_size(encryptetText, encryptetText2)
	sync_position_and_size(applybutton, applybutton2)
	sync_position_and_size(histogram, histogram2)
	sync_position_and_size(shift_down_button, shift_down_button2)
	sync_position_and_size(shift_up_button, shift_up_button2)
	sync_position_and_size(shift_label, shift_label2)
	sync_transform(rad_sprite, rad_sprite2)

	$Anmerkung.visible = false
	$Anmerkung/Richtig.visible = false
	$Anmerkung/Falsch.visible = false

	float_actor(kapitän)
	float_actor(funker)
	float_actor(mechaniker)
	float_actor(elderaxolotl)

	$CaesarMinigame.decrypted_successfully.connect(_on_decrypted_successfully)
	$CaesarMinigame.decrypted_unsuccessfully.connect(_on_decrypted_unsuccessfully)
	$ZweiCaesarMinigame2.decrypted_successfully.connect(_on_decrypted_successfully)
	$ZweiCaesarMinigame2.decrypted_unsuccessfully.connect(_on_decrypted_unsuccessfully)

	funker.visible = false
	mechaniker.visible = false
	elderaxolotl.visible = false

	if GameState.skip_explanations:
		set_skipped_lines([10, 11, 12, 13, 14, 15, 16, 17])
		print("Signal angekommen")

	weiter_button.pressed.connect(on_weiter_text_button_pressed)
	await get_tree().create_timer(1.0).timeout

	await show_next_text()

func activate_script() -> void:
	set_process(true)
	set_physics_process(true)
	hintergrundsound.play()
	if GameState.jump_to_text_index >= 0:
		current_text_index = GameState.jump_to_text_index
		GameState.jump_to_text_index = -1
		print("Sprung Spiel1")
		# Alle Effekte bis zur Sprung-Zeile simulieren
		#for i in range(current_text_index):
			#await play_effect_for_line(i)
	if current_text_index < dialog_texts.size():
		await show_next_text()

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

#wird ausgelöst wenn Entschlüsselung erfolgreich ist 
func _on_decrypted_successfully() -> void:
	$WeiterTextButton.disabled = false
	$CaesarMinigame/ApplyButton.disabled = true
	print("Text wurde erfolgreich entschlüsselt!")
	fade_in(anmerkung)
	fade_in(richtig)
	await get_tree().create_timer(6.0).timeout
	fade_out(anmerkung)
	fade_out(richtig)

#wird ausgelöst wenn Entschlüsselung  nicht erfolgreich ist 
func _on_decrypted_unsuccessfully() -> void:
	fade_in(anmerkung)
	fade_in(falsch)
	await get_tree().create_timer(6.0).timeout
	fade_out(anmerkung)
	fade_out(falsch)

#lässt Node farbig aufblinken und wird leicht vergrößert 
func flash_node_blinking_effect(node: Node, color: Color = Color(1, 1, 0.3), duration := 2.0, frequency := 4.0, scale_factor := 1.1) -> void:
	if node == null:
		return

	var tween := get_tree().create_tween()
	var original_color: Color = node.modulate
	var original_scale: float = node.scale

	var total_blinks := int(duration * frequency)
	var on := true

	# Starte mit sanftem Aufblasen
	tween.tween_property(node, "scale", original_scale * scale_factor, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	# Blinksequenz (Farbe wechselt schnell)
	for i in range(total_blinks):
		var next_color := color if on else original_color
		tween.tween_property(node, "modulate", next_color, 0.1)
		on = !on

	# Rückkehr zur Originalfarbe und -größe
	tween.tween_property(node, "modulate", original_color, 0.2)
	tween.tween_property(node, "scale", original_scale, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

#lässt Node kurz vergrößern 
func scale_pulse(node: Node, scale_factor: float = 1.2, duration: float = 0.4) -> void:
	await get_tree().create_timer(1.5).timeout
	if node == null:
		return

	var tween := get_tree().create_tween()
	var original_scale: Vector2 = node.scale

	# Vergrößern
	tween.tween_property(
		node, "scale", original_scale * scale_factor, duration * 0.5
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	# Zurück zur Ursprungsgröße
	tween.tween_property(
		node, "scale", original_scale, duration * 0.5
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

#Synchronisation Funktion
func sync_position_and_size(from: Control, to: Control) -> void:
	if from and to:
		to.position = from.position
		to.size = from.size
		to.scale = from.scale
		to.pivot_offset = from.pivot_offset

func sync_transform(from: Node2D, to: Node2D) -> void:
	if from and to:
		to.position = from.position
		to.scale = from.scale
		to.rotation = from.rotation

func transition_to_scene02() -> void:
	var spiel01 := self
	var spiel02 := get_parent().get_node("Spiel02")

	# Spiel02 vorbereiten (unsichtbar aber aktiv)
	spiel02.visible = true
	spiel02.modulate.a = 0.0  # Start transparent

	# Spiel01 ausfaden
	await fade_out(spiel01, 2.0)
	spiel01.visible = false
	
	await get_tree().create_timer(1.0).timeout
	# Spiel02 einfaden
	await fade_in(spiel02, 3.0)
	spiel02.activate_script()

	# Dieses Script deaktivieren
	set_process(false)
	set_physics_process(false)
	$WeiterTextButton.disabled = true

func set_skipped_lines(lines: Array[int]) -> void:
	skipped_lines = lines

func play_effect_for_line(index: int) -> void:
	match index:
		3:
			kapitän.visible = false
			mechaniker.visible = true
			
		4:
			kapitän.visible = true
			mechaniker.visible = false
		6:
			kapitän.visible = false
			funker.visible = true
		7:
			kapitän.visible = true
			funker.visible = false
		8:
			kapitän.visible = false
			funker.visible = true
		9:
			fade_in(radiostation)
			fade_in(encryptetText)
			fade_in(cheatsheet)
		10:
			#caesarminigame.reset()
			elderaxolotl.visible = true
			funker.visible = false
			kapitän.visible = false
			encryptetText.visible = true
			radiostation.visible = true
			cheatsheet.visible = true
		16:
			fade_in(histogram)
			scale_pulse(histogram, 1.3, 1.0)
		17:
			#caesarminigame.reset()
			#caesarminigame.original_text = "hi"
			fade_in(shift_down_button)
			fade_in(shift_label)
			fade_in(shift_up_button)
			fade_in(applybutton)
			fade_in(sprite2D)
			fade_in(fixedEncryptedtext)
			$WeiterTextButton.disabled = true
			
		18:
			elderaxolotl.visible = false
			funker.visible = true
		19:
			kapitän.visible = true
			funker.visible = false
		20:
			kapitän.visible = false
			funker.visible = true
			#caesarminigame2.reset()
			caesarminigame2.visible = true
			caesarminigame.visible = false
			$WeiterTextButton.disabled = true
		21:
			kapitän.visible = true
			funker.visible = false
		22:
			fade_out_sound_and_stop(hintergrundsound, 2.0)
			await transition_to_scene02()

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

func fade_out_sound_and_stop(player: AudioStreamPlayer, duration: float = 2.0) -> void:
	var tween := get_tree().create_tween()
	tween.tween_property(player, "volume_db", -80.0, duration)
	await tween.finished
	player.stop()

func hintergrund_sound_nacht() -> void:
	AudioManager.create_2d_audio_at_location(Vector2(200,400), SoundEffect.SOUND_EFFECT_TYPE.CRICKET)
