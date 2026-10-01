extends Node2D

signal circuit_evaluated(index:int, correct: bool)

const GATE_SCENE: PackedScene = preload("uid://ysn402ro3voe")
const CONNECTOR_SCENE: PackedScene = preload("uid://bw7cdhf5tkcn2")

var bonus_connector_in: CompressedTexture2D = preload("uid://6mw16vh7ips8")
var bonus_connector_out: CompressedTexture2D = preload("uid://t3wxaloufq5g")
var bonus_wire: CompressedTexture2D = preload("uid://bea3bsopt22n3")
var bonus_gate: CompressedTexture2D = preload("uid://8lmcscj35smg")
var bonus_gate_type: CompressedTexture2D = preload("uid://u1sdwim1ssin")

enum STYLE {
	MAINLEVEL,
	BONUSLEVEL
}

@export var style: STYLE = STYLE.MAINLEVEL

@onready var result_label: Label = %ResultLabel
@onready var expression_input: TextEdit = %ExpressionInput
@onready var spawn_point: Marker2D = %SpawnPoint
@onready var components: Node2D = %Components
@onready var gates: Node2D = %Gates
@onready var connectors: Node2D = %Connectors
@onready var static_components: Node2D = %StaticComponents
@onready var evaluation_animation: AnimatedSprite2D = %EvaluationAnimation
@onready var delete_panel: Sprite2D = %DeletePanel

@onready var formatted_input_field: Control = %FormattedInputField
@onready var input_string_label: Label = %LabelInputString

@onready var result_led: Sprite2D = %LED

# example: "(values[0] or values[2]) and values[3]"
# # where values[0] is the value of InputA, values[1] is the value of InputB, etc.
@export var expression: String = ""

@onready var output: Connector = %Output

@onready var bbox: ColorRect = %BBox

@onready var inputs: Array[Connector] = [
	%InputA,
	%InputB,
	%InputC,
	%InputD,
	%InputE
]

@export var my_index: int = -1

func _ready() -> void:

	if style == STYLE.BONUSLEVEL:
		for connector: Connector in static_components.get_children():
			if connector is Connector:
				connector.connectorIn.set_texture(bonus_connector_in)
				connector.connectorOut.set_texture(bonus_connector_out)
				connector.wire.set_texture(bonus_wire)

	SignalBus.draggable_node_picked.connect(_on_draggable_node_picked)
	SignalBus.draggable_node_dropped.connect(_on_draggable_node_dropped)

	Vars.circuit_bbox_size = bbox.size

	var new_material := result_led.material.duplicate()
	result_led.material = new_material

func on_evaluate() -> void:
	# evalutes the circuit based on the expression in the input field

	evaluation_animation.show()
	evaluation_animation.play("animation")

	print_to_label("Evaluating circuit...")

	var circuit_correct: bool = true

	var expr: Expression = Expression.new()
	var error := expr.parse(expression, ["values"])
	if error != OK:
		self.print_to_label("Error parsing expression: " + str(error))
		return

	for i in range(32):
		var test_values := []
		for bit in range(5):
			test_values.append((i >> bit) & 1 == 1)

		var result: bool = expr.execute([test_values], self)
		if expr.has_execute_failed():
			self.print_to_label("Error executing expression with values " + str(test_values) + ": " + expr.get_error_text())
			continue

		var test_result := await self.test_config(test_values)

		if i % 2 == 0:
			AudioManager.create_2d_audio_at_location(output.global_position, SoundEffect.SOUND_EFFECT_TYPE.MODEM)

		if result != test_result:
			circuit_correct = false

	SignalBus.circuit_evaluated.emit(circuit_correct)
	circuit_evaluated.emit(my_index, circuit_correct)
	self.update_led(circuit_correct)
	self.print_to_label("Result: " + str(circuit_correct))

	evaluation_animation.hide()

func test_config(_values: Array) -> bool:
	# tests a specific configuration of the circuit, called by on_evaluate()

	for input: Connector in inputs:
		if input == null:
			continue
		var index: int = inputs.find(input)
		if index < 0 or index >= _values.size():
			continue
		input.set_value(_values[index])

	await get_tree().process_frame
	var result: bool = output.evaluate()

	await get_tree().create_timer(0.1).timeout # just because it looks better if the leds are blinking

	return result

func print_to_label(_text: String) -> void:
	result_label.text = _text

func _on_button_add_and_pressed() -> void:
	self.instantiate_gate(Gate.GateType.AND)

func _on_button_add_or_pressed() -> void:
	self.instantiate_gate(Gate.GateType.OR)

func _on_button_add_xor_pressed() -> void:
	self.instantiate_gate(Gate.GateType.XOR)

func _on_button_add_not_pressed() -> void:
	self.instantiate_gate(Gate.GateType.NOT)

func instantiate_gate(gate_type: Gate.GateType) -> void:
	var new_gate: Gate = GATE_SCENE.instantiate()
	new_gate.position = spawn_point.position

	new_gate.type = gate_type
	gates.add_child(new_gate)

	if style == STYLE.BONUSLEVEL:
		new_gate.base.set_texture(bonus_gate)
		new_gate.input_a_sprite.set_texture(bonus_connector_in)
		new_gate.input_b_sprite.set_texture(bonus_connector_in)
		new_gate.output_sprite.set_texture(bonus_connector_out)
		new_gate.type_sprite.set_texture(bonus_gate_type)
	
	new_gate.type = gate_type
	

func _on_button_add_wire_pressed() -> void:
	var new_connector: Connector = CONNECTOR_SCENE.instantiate()
	new_connector.position = spawn_point.position

	connectors.add_child(new_connector)

	if style == STYLE.BONUSLEVEL:
		new_connector.connectorIn.set_texture(bonus_connector_in)
		new_connector.connectorOut.set_texture(bonus_connector_out)
		new_connector.wire.set_texture(bonus_wire)

func reset() -> void:
	#get_viewport().gui_get_focus_owner().release_focus()
	var clists: Array[Node2D] = [gates, connectors]
	for list: Node2D in clists:
		for component: Node in list.get_children():
			component.queue_free()

	for wire: Node in static_components.get_children():
		if wire is Connector:
			wire.reset_position()

	self.update_led(false)

# call this to set the expression from outside or set using the @export variable
func set_expression(_expression: String) -> void:
	expression = _expression

	var replacements: Dictionary = {
		"values[0]": "A",
		"values[1]": "B",
		"values[2]": "C",
		"values[3]": "D",
		"values[4]": "E",
	}

	for key: String in replacements.keys():
		_expression = _expression.replace(key, replacements[key])

	expression_input.text = _expression

func _on_delete_panel_input(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventScreenTouch:
		if !event.pressed:
			var last_dragged_panel: Node = TouchController.last_dragged_panel
			if last_dragged_panel == null:
				return
			if last_dragged_panel.name == "Base" or last_dragged_panel.name.contains("Connector") or last_dragged_panel.name == "DragPoint":
				last_dragged_panel.delete_parent()

func _on_draggable_node_picked(node: Draggable_Node) -> void:
	if node == null:
		return

	var tween: Tween = get_tree().create_tween()
	if node.deletable and node.global_position.distance_to(delete_panel.global_position) < Vars.circuit_bbox_size.x * self.scale.x * 0.95:
		tween.tween_property(delete_panel, "modulate", Color(1, 1, 1, 0.5), 0.2)
	else:
		tween.tween_property(delete_panel, "modulate", Color(1, 1, 1, 0), 0.2)

func _on_draggable_node_dropped(_node: Draggable_Node) -> void:
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(delete_panel, "modulate", Color(1, 1, 1, 0), 0.2)

func update_led(state: bool) -> void:
	result_led.material.set_shader_parameter("enabled", state)

func set_formatted_input_string(input_string: String) -> void:
	input_string_label.text = input_string

func enable_buttons(enable: bool) -> void:
	%ButtonAddAND.disabled = !enable
	%ButtonAddOR.disabled = !enable
	%ButtonAddXOR.disabled = !enable
	%ButtonAddNOT.disabled = !enable
	%ButtonAddWire.disabled = !enable
	%ButtonReset.disabled = !enable
	%ButtonEvaluate.disabled = !enable
