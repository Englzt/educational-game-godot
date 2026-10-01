extends Node2D

@onready var switches: Node2D = %Switches
@onready var target_value_label: Label = %LabelTargetValue

var asteroid: Node = null
var my_index: int = -1
var has_submitted: bool = false

signal submitted(index: int, correct: bool)

var values: Array[bool] = [false, false, false, false, false, false, false, false]

func _ready() -> void:
	for switch: Node in switches.get_children():
		if not switch.state_changed.is_connected(_on_switch_state_changed):
			switch.state_changed.connect(_on_switch_state_changed)

func set_target_value(value: int) -> void:
	target_value_label.text = str(value)

func _on_switch_state_changed(index: int, state: bool) -> void:
	values[index] = state

func get_value() -> int:
	var decimal_value: int = 0
	for i in range(0, 8):
		var state: bool = values[i]

		@warning_ignore("narrowing_conversion")
		decimal_value += int(state) * pow(2, i)

	return decimal_value

func set_asteroid(node: Node) -> void:
	asteroid = node

func set_my_index(idx: int) -> void:
	my_index = idx

func reset() -> void:
	has_submitted = false
	values = [false, false, false, false, false, false, false, false]
	target_value_label.text = "---"

	for switch: Node in switches.get_children():
		switch.reset()

func _on_button_fire_pressed() -> void:
	if not target_value_label.text.is_valid_int():
		## quick and dirty check to prevent firing before the target value is set
		return
	
	SignalBus.binary_submitted.emit(self.get_value())
	
	var correct: bool = false
	if asteroid != null:
		correct = (get_value() == asteroid.health)
		
	submitted.emit(my_index, correct)
