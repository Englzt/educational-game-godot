class_name Gate extends Node2D

enum GateType {
	AND,
	OR,
	XOR,
	NOT
}

@export var type: GateType = GateType.AND

@export var input_a: Connector
@export var input_b: Connector
@export var output: Connector

@onready var input_a_anchor: Area2D = %InputAnchorA
@onready var input_b_anchor: Area2D = %InputAnchorB
@onready var output_anchor: Area2D = %OutputAnchor

@onready var led: Sprite2D = %LED

@onready var type_sprite: Sprite2D = %GateTypeSprite

@onready var debug: RichTextLabel = %Debug

@onready var base: Draggable_Node = %Base

@onready var input_a_sprite: Sprite2D = %InputASprite
@onready var input_b_sprite: Sprite2D = %InputBSprite
@onready var output_sprite: Sprite2D = %OutputSprite

@export var deletable: bool = true

var parent_rotation: int = 0

func _ready() -> void:
	# Connect the input signals to the gate
	TouchController.register_draggable_node(base)
	base.DraggableNodeMoved.connect(_on_base_moved)

	base.deletable = deletable

	input_a_anchor.add_to_group("gate_io")

	if type == GateType.NOT:
		input_b_anchor.hide()
		input_b_anchor.get_node("CollisionShape2D").disabled = true
	else:
		input_b_anchor.add_to_group("gate_io")

	output_anchor.add_to_group("gate_io")

	type_sprite.set_region_rect(Rect2(type * 70, 0, 70, 90))

	var new_material := led.material.duplicate()
	led.material = new_material

	self.update_led(false, false)

func evaluate(visited: Dictionary = {}) -> bool:

	# check circular redundancy -> leads to infinite loop and crash
	if self in visited:
		return false

	visited[self] = true

	var a_value: bool = input_a != null and input_a.evaluate(visited)
	var b_value: bool = input_b != null and input_b.evaluate(visited)

	var value: bool = false

	match type:
		GateType.AND:
			value = a_value and b_value
		GateType.OR:
			value = a_value or b_value
		GateType.NOT:
			value = not a_value
		GateType.XOR:
			value = a_value != b_value

	self.update_led(true, value)
	return value

func _on_base_moved(_node: Node) -> void:

	position += base.position
	base.position = Vector2.ZERO

	var gate_io_list: Array = [input_a, input_b, output]
	for gate_io: Connector in gate_io_list:
		if gate_io == null:
			continue
		
		# move the connector to the anchor position
		if gate_io == input_a:
			gate_io.connectorOut.global_position = input_a_anchor.global_position
		
		if gate_io == input_b:
			gate_io.connectorOut.global_position = input_b_anchor.global_position
		
		if gate_io == output:
			gate_io.connectorIn.global_position = output_anchor.global_position
		
		if gate_io:
			gate_io.update_wire()

	position.x = clamp(position.x, 0, Vars.circuit_bbox_size.x - base.get_size().x)
	position.y = clamp(position.y, 0, Vars.circuit_bbox_size.y - base.get_size().y)

func add_connector(connector: Connector, gate_slot: String, connector_slot: String) -> bool:
	# add a connector to the gate
	# its only possible to connect an ConnectorOut to an InputAnchor and an ConnectorIn to an OutputAnchor

	var result: bool = false

	match gate_slot:
		"InputAnchorA":
			if connector_slot == "ConnectorIn":
				return false
			input_a = connector
			result = true
		"InputAnchorB":
			if connector_slot == "ConnectorIn":
				return false
			input_b = connector
			result = true
		"OutputAnchor":
			if connector_slot == "ConnectorOut":
				return false
			output = connector
			result = true

	AudioManager.create_2d_audio_at_location(connector.global_position, SoundEffect.SOUND_EFFECT_TYPE.PLUG_IN)

	self.update_debug()
	self.update_led(false, false)

	return result

func remove_connector(connector: Connector) -> void:
	if connector == input_a:
		input_a = null
	elif connector == input_b:
		input_b = null
	elif connector == output:
		output = null

	AudioManager.create_2d_audio_at_location(connector.global_position, SoundEffect.SOUND_EFFECT_TYPE.PLUG_OUT)

	self.update_debug()
	self.update_led(false, false)

func update_debug() -> void:
	var a_text := str(input_a.name) if input_a != null else "null"
	var b_text := str(input_b.name) if input_b != null else "null"
	var o_text := str(output.name) if output != null else "null"

	debug.text = "A: " + a_text + "\nB: " + b_text + "\nO: " + o_text

func update_led(state_override: bool, state: bool) -> void:
	if !state_override:
		state = self.evaluate()
	led.material.set_shader_parameter("enabled", state)

	if !state_override:
		self.propagate_forward()

func propagate_forward(visited: Dictionary = {}) -> void:
	if output != null:
		output.propagate(visited)
