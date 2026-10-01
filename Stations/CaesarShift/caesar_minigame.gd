extends Control

#Signale für Entschlüsselung
signal decrypted_successfully
signal decrypted_unsuccessfully
signal cooldown_started

#Export un interne Variablen 
@export var original_text := "DAMIT DAS FUNKTIONIERT BRAUCHEN WIR EINEN SEHR LANGEN TEXT DAMIT MEHRERE BUCHSTABEN VORKOMMEN"
@export var shift := 4
@export var shiftzeigen := 4
@export var histogrammanzeige := 8

@export var enable_cooldown: bool = false
@export var cooldown_time: float = 3.0
@export var cooldown_threshold: int = 3
var input_error_counter: int = 0
var input_error_counter_total: int = 0
@onready var cooldown_timer: Timer = %CooldownTimer

var encrypted := ""
var letters := ""
var freq: Dictionary = {}

#ONready-Referenzen zu UI-Elementen
@onready var spin_box := $SpinBox
@onready var rad_sprite := $rad_sprite 
@onready var shift_label := $ShiftLabel
@onready var shift_up_button := $ShiftUpButton
@onready var shift_down_button := $ShiftDownButton

@onready var cooldown_timer_panel: HBoxContainer = %CooldownTimerPanel
@onready var cooldown_timer_label: Label = %LabelCooldownTimer

#wird beim Start aufgerufen
func _ready() -> void:
	cooldown_timer_panel.visible = false	
	cooldown_timer.timeout.connect(_on_cooldown_timeout)

	$rad_sprite.shift_changed.connect(_on_rad_shift_changed)
	shift_up_button.pressed.connect(_on_shift_up)
	shift_down_button.pressed.connect(_on_shift_down)
	update_shift_ui()

	encrypted = caesar_encrypt(original_text, shiftzeigen)
	letters = original_text
	show_encrypted()
	show_letters()
	show_fixed_encrypted()
	randomize()
	show_histogram()
	
	connect("decrypted_successfully", Callable(self, "_on_decrypted_successfully"))
		
	shift = 0  
	_on_rad_shift_changed(shift)
	update_shift_ui()

func _process(_delta: float) -> void:
	if enable_cooldown and !cooldown_timer.is_stopped():
		cooldown_timer_label.text = str(int(cooldown_timer.time_left)) + "s"
		return

#Zeigt Originaltext als Labels im Container "Decrypted Text"
func show_letters() -> void:
	for c in original_text:
		var lbl: Label = Label.new()
		lbl.text = c
		$DecryptedText.add_child(lbl)

#wird aufgrufen, wenn sich der Drehwinkel änert, aktualisiert den Winkel und die UI
func _on_rad_shift_changed(new_shift: int) -> void:
	shift = new_shift
	spin_box.value = new_shift
	update_shift_ui()

	var step: float = 360.0 / 26.0
	rad_sprite.dial.rotation_degrees = -0 + shift * step

#Zeigt den verhsclüsseltem Text als Label im Container "Encrypted Text"
func show_encrypted() -> void:
	# Leeren Dummy-Label für gleichmäßigen Rand einfügen
	var dummy := Label.new()
	dummy.text = " "  # Echtes Leerzeichen
	dummy.visible = false  # unsichtbar, aber beeinflusst Layout
	$EncryptedText.add_child(dummy)


	var words := encrypted.split(" ")
	for word in words:
		var lbl := Label.new()
		lbl.text = " " + word  # immer mit Leerzeichen vorne
		$EncryptedText.add_child(lbl)


#Zeigt die Verschlüsselung des Originaltextes 
func show_fixed_encrypted() -> void:
	var fixed_encrypted: String = caesar_encrypt(original_text, 4)

	var words := fixed_encrypted.split(" ")
	for word in words:
		var lbl := Label.new()
		lbl.text = " " + word
		$FixedEncryptedText.add_child(lbl)


#Führt die Caesar-Verschlüsselung aus, nur groß Buchstaben
func caesar_encrypt(text: String, shift_amt: int) -> String:
	var result := ""
	for c in text:
		if c >= "A" and c <= "Z":
			var normalized := c.unicode_at(0) - 65
			var shifted := (normalized + shift_amt) % 26
			if shifted < 0:
				shifted += 26  
			result += char(shifted + 65)
		else:
			result += c
	return result

#Animiert die Entschlüsselung und sendet Signal bei Erfolg/Fehlschlag
func update_encrypted() -> void:
	$ApplyButton.disabled = true

	# Nur Kinder ab Index 1 löschen (Dummy behalten)
	for i in range($FixedEncryptedText.get_child_count()):
		var child := $FixedEncryptedText.get_child(i)
		if is_instance_valid(child):
			child.queue_free()

	# Entschlüsselten Text vorbereiten
	var final_text: String = caesar_encrypt(encrypted, -shift)
	var words := final_text.split(" ")
	var labels: Array[Label] = []

	# Platzhalter erzeugen – Dummy ist bereits vorhanden bei Index 0
	for word in words:
		var lbl := Label.new()
		lbl.text = " " + word  # Initialtext für Animation
		$FixedEncryptedText.add_child(lbl)
		labels.append(lbl)

	AudioManager.create_2d_audio_at_location($FixedEncryptedText.global_position, SoundEffect.SOUND_EFFECT_TYPE.RADIO_STATIC)

	# Animation mit Zufallsbuchstaben
	for iteration in range(7):
		await get_tree().create_timer(0.05).timeout
		for lbl in labels:
			var rand_word := ""
			for c in lbl.text.strip_edges():
				rand_word += get_random_letter()
			lbl.text = " " + rand_word

	# Finaler Text setzen
	await get_tree().create_timer(0.1).timeout
	var _is_first := true
	for i in range(labels.size()):
		if i < words.size():
			labels[i].text = " " + words[i]

		_is_first = false

	# Erfolg prüfen
	if final_text == original_text:
		input_error_counter = 0
		decrypted_successfully.emit()
		SignalBus.code_decrypted.emit(final_text)
	else:
		input_error_counter += 1
		input_error_counter_total += 1
		decrypted_unsuccessfully.emit()

		if enable_cooldown and input_error_counter >= cooldown_threshold:
			cooldown_started.emit()
			cooldown_timer_panel.visible = true
			cooldown_timer.wait_time = input_error_counter_total * cooldown_time
			cooldown_timer.one_shot = true
			cooldown_timer.start()
			cooldown_timer_label.text = str(int(cooldown_timer.wait_time)) + "s"
			$ApplyButton.disabled = true
			return

	$ApplyButton.disabled = false

func _on_cooldown_timeout() -> void:
	cooldown_timer_panel.visible = false
	$ApplyButton.disabled = false
	input_error_counter = 0

#Gibt zufälligen Buchstaben zurück
func get_random_letter() -> String:
	return char(randi() % 26 + 65)  # A–Z

#Passt den Winkel des Rades an
func _on_spin_box_value_changed(value: float) -> void:
	shift = int(value)
	var step: float = 360.0 / 26.0
	rad_sprite.dial.rotation_degrees = -0 + (shift + 0.5) * step

#Erhöht den Shift-Wert und rotiert das Rad entsprechend 
func _on_shift_up() -> void:
	shift = (shift + 1) % 26
	update_shift_ui()
	$rad_sprite.dial.rotation_degrees = -270 + (shift + 0.5) * (360.0 / 26.0)
	$rad_sprite.emit_signal("shift_changed", shift)
	AudioManager.create_2d_audio_at_location(rad_sprite.global_position, SoundEffect.SOUND_EFFECT_TYPE.RADIO_TURN_SOUND_1)

#Verringert den Shift-Wert und rotiert das Rad entsprechend 
func _on_shift_down() -> void:
	shift = (shift - 1 + 26) % 26
	update_shift_ui()
	$rad_sprite.dial.rotation_degrees = -270 + (shift + 0.5) * (360.0 / 26.0)
	$rad_sprite.emit_signal("shift_changed", shift)
	AudioManager.create_2d_audio_at_location(rad_sprite.global_position, SoundEffect.SOUND_EFFECT_TYPE.RADIO_TURN_SOUND_1)

#Aktualisiert das Label für die aktuelle Verschiebung
func update_shift_ui() -> void:
	shift_label.text = str(shift)

#Startet die Verschlüsselungsanimation 
func _on_apply_button_pressed() -> void:
	update_encrypted()

#Histogram der Buchstabenhäufigkeit aus de mverschlüssleten Text
func show_histogram() -> void:
	for child in $HistogramContainer.get_children(): # alle alten Einträge entfernen
		child.queue_free()
 

	freq = count_letter_frequencies(encrypted)  # oder fixed_encrypted
	self.freq = freq

	# Maximalwert für Normierung
	var max_count: int = 1
	for count: int in freq.values():
		max_count = max(max_count, count)
	
	var letters_array: Array = Array(freq.keys())
	letters_array.sort_custom(func(a: String, b: String) -> int: return freq[a] > freq[b])
	letters_array = letters_array.slice(0, histogrammanzeige)

	for letter: String in letters_array:
		var hbox: HBoxContainer = HBoxContainer.new()

	# Buchstabe links
		var label: Label = Label.new()
		label.text = "%s" % letter
		label.custom_minimum_size.x = 20
		hbox.add_child(label)

		# Balken in Farbverlauf
		var bar: ColorRect = ColorRect.new()
		var rel: float = freq[letter] / float(max_count)
		var intensity: float = lerp(1.0, 0.2, rel)  # je höher, desto dunkler
		bar.color = Color(intensity, 0.5, 1)
		bar.custom_minimum_size = Vector2(5 + 200.0 * rel, 20)
		hbox.add_child(bar)

		# Zählwert rechts daneben
		var count_label: Label = Label.new()
		count_label.text = "%d" % freq[letter]
		count_label.custom_minimum_size.x = 30
		hbox.add_child(count_label)

		$HistogramContainer.add_child(hbox)

#Vergleichfunktion für Sortierung der Häufigkeit
func _sort_by_frequency(a: int, b: int) -> bool:
	return freq[a] > freq[b]

#Zählt die Häufigkeit jedes Buchstaben im Text
func count_letter_frequencies(text: String) -> Dictionary:
	freq = {}
	for c in text:
		if c >= "A" and c <= "Z":
			if not freq.has(c):
				freq[c] = 0
			freq[c] += 1
	return freq

func reset() -> void:
	var clear_queue := [$EncryptedText, $DecryptedText, $FixedEncryptedText, $HistogramContainer]
	for container: Control in clear_queue:
		for child in container.get_children():
			child.queue_free()

	shift = 0
	spin_box.value = shift
	rad_sprite.dial.rotation_degrees = 0
	update_shift_ui()

	input_error_counter = 0
	input_error_counter_total = 0
	
	# Dummy-Label neu anlegen, da alles gelöscht wurde
	var dummy := Label.new()
	dummy.text = " "
	dummy.visible = false
	$FixedEncryptedText.add_child(dummy)


func set_plain_text(text: String) -> int:
	
	self.reset()

	original_text = text.to_upper()
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	shiftzeigen = rng.randi_range(1, 25)
	# prints("shiftzeigen: ", shiftzeigen)
	# prints("shift: ", shift)
	encrypted = caesar_encrypt(original_text, shiftzeigen)
	letters = original_text
	show_encrypted()
	randomize()
	show_histogram()

	return shiftzeigen
