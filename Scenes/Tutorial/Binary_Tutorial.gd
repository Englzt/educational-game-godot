extends Node2D
#test

@export var target_value: int = 0

@onready var switches: Node2D = %Switches
@onready var target_value_label: Label = %LabelTargetValue
@onready var current_value_label: Label = $Control/VBoxContainer/Control/LabelCurrentValue
@onready var button_show_value: TextureButton = $Control/VBoxContainer/Control/ButtonShowValue
@onready var label_current_value: Label = $Control/VBoxContainer/Control/LabelCurrentValue



signal value_correct
signal value_wrong


var my_index: int = -1
var has_submitted: bool = false

@warning_ignore("unused_signal")
signal submitted(index: int, correct: bool)

var values: Array[bool] = [false, false, false, false, false, false, false, false]
var value := get_value()

func _ready() -> void:
	if button_show_value == null:
		push_error("⚠️ ButtonShowValue konnte nicht gefunden werden!")
	else:
		button_show_value.pressed.connect(_on_button_show_value_pressed)
		
	#button_show_value.pressed.connect(_on_button_show_value_pressed)
	for switch: Node in switches.get_children():
		if not switch.state_changed.is_connected(_on_switch_state_changed):
			switch.state_changed.connect(_on_switch_state_changed)
			
	set_target_value(target_value)
	$Control/VBoxContainer/Control/LabelCurrentValue.visible = false

func set_target_value(_value: int) -> void:
	target_value_label.text = str(_value)

func _on_switch_state_changed(index: int, state: bool) -> void:
	values[index] = state
	#current_value_label.text = str(get_value())

func get_value() -> int:
	var decimal_value: int = 0
	for i in range(0, 8):
		var state: bool = values[i]

		@warning_ignore("narrowing_conversion")
		decimal_value += int(state) * pow(2, i)

	return decimal_value

func set_my_index(idx: int) -> void:
	my_index = idx

func reset() -> void:
	has_submitted = false
	values = [false, false, false, false, false, false, false, false]
	target_value_label.text = "0"
	
	for switch: Node in switches.get_children():
		if "reset" in switch:
			switch.reset()

func _on_button_fire_pressed() -> void:
	var _value := get_value()
	
	if _value == target_value:
		emit_signal("value_correct")
	else:
		emit_signal("value_wrong")

func _on_button_show_value_pressed() -> void:
	$Control/VBoxContainer/Control/LabelCurrentValue.visible = true
	var current := get_value()
	label_current_value.text = "Dein Aktueller Wert beträgt: " + str(current)
	await get_tree().create_timer(4.0).timeout
	$Control/VBoxContainer/Control/LabelCurrentValue.visible = false
