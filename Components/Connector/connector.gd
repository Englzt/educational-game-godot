class_name Connector extends Node2D

@export var set_manually: bool
@export var manual_value: bool = false

@export var input_immoveable: bool = false
@export var output_immoveable: bool = false

@export var deletable: bool = true

@export var input_connection: Gate
@export var output_connection: Gate

@onready var wire: Line2D = %Wire
@onready var connectorIn: Draggable_Node = %ConnectorIn
@onready var connectorOut: Draggable_Node = %ConnectorOut
@onready var drag_point: Draggable_Node = %DragPoint

@onready var led: Sprite2D = %LED

var drag_point_offsets: Dictionary = {
	"ConnectorIn": Vector2(0, 0),
	"ConnectorOut": Vector2(0, 0),
}

var parent_rotation: int = 0

func _ready() -> void:

	if !input_immoveable:
		TouchController.register_draggable_node(connectorIn)
		connectorIn.DraggableNodeMoved.connect(_on_connector_moved)
	
	if !output_immoveable:
		TouchController.register_draggable_node(connectorOut)
		connectorOut.DraggableNodeMoved.connect(_on_connector_moved)

	if !input_immoveable and !output_immoveable:
		TouchController.register_draggable_node(drag_point)
		drag_point.DraggableNodeMoved.connect(_on_drag_point_moved)
		self.update_drag_point()
	else:
		drag_point.hide()

	connectorIn.deletable = deletable
	connectorOut.deletable = deletable

	var new_material := led.material.duplicate()
	led.material = new_material

	self.update_wire()
	self.update_led(false, false)

func set_value(value: bool) -> void:
	manual_value = value
	self.update_led(true, manual_value)

func evaluate(visited: Dictionary = {}) -> bool:
	if set_manually:
		return manual_value

	if input_connection == null:
		return false
	
	var value: bool = input_connection.evaluate(visited)
	self.update_led(true, value)

	return value

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if !event.pressed:
			self.check_disconnect()

			var input_collision: Dictionary = self.check_for_gate_io_collision(connectorIn)
			var output_collision: Dictionary = self.check_for_gate_io_collision(connectorOut)

			if input_connection == null and input_collision.collider != null:
				var gate: Gate = input_collision.collider.get_owner()
				var valid: bool = gate.add_connector(self, input_collision.collider.name, input_collision.connector.name)
				if valid:
					input_connection = gate
					input_collision.connector.global_position = input_collision.collider.global_position# - input_collision.connector.get_size() / 2

			if output_connection == null and output_collision.collider != null:
				var gate: Gate = output_collision.collider.get_owner()
				var valid: bool = gate.add_connector(self, output_collision.collider.name, output_collision.connector.name)
				if valid:
					output_connection = gate
					output_collision.connector.global_position = output_collision.collider.global_position# - output_collision.connector.get_size() / 2

			self.update_wire()

func _on_connector_moved(_node: Node2D) -> void:

	var new_position: Vector2 = _node.position
	new_position.x = clamp(position.x + _node.position.x, 0, Vars.circuit_bbox_size.x - _node.get_size().x / 2)
	new_position.y = clamp(position.y + _node.position.y, 0, Vars.circuit_bbox_size.y - _node.get_size().y / 2)
	_node.position = new_position - position
	# prints("Moved: ", _node.name, " ", position + _node.position)
	self.check_disconnect()
	self.update_drag_point()
	self.update_wire()

func _on_drag_point_moved(_node: Node2D) -> void:
	# prints("Drag Point Moved: ", _node.name, " ", position + _node.position)
	var new_position: Vector2 = _node.position
	new_position.x = clamp(position.x + _node.position.x, 0, Vars.circuit_bbox_size.x - _node.get_size().x / 2)
	new_position.y = clamp(position.y + _node.position.y, 0, Vars.circuit_bbox_size.y - _node.get_size().y / 2)
	_node.position = new_position - position
	connectorIn.position = _node.position - drag_point_offsets["ConnectorIn"]
	connectorOut.position = _node.position - drag_point_offsets["ConnectorOut"]
	self.check_disconnect()
	self.update_wire()

func update_wire() -> void:
	@warning_ignore("narrowing_conversion")
	var wire_width_offset: int = wire.get_width() / 1.3
	wire.clear_points()
	wire.add_point(connectorIn.position - Vector2(wire_width_offset, wire_width_offset))
	wire.add_point(connectorOut.position - Vector2(wire_width_offset, wire_width_offset))
	self.update_drag_point()
	self.update_led(false, false)

func update_drag_point() -> void:
	drag_point.position = (connectorIn.position + connectorOut.position) / 2
	drag_point_offsets["ConnectorIn"] = drag_point.position - connectorIn.position
	drag_point_offsets["ConnectorOut"] = drag_point.position - connectorOut.position

func check_for_gate_io_collision(connector: Draggable_Node) -> Dictionary:
	var area: Area2D = connector.get_node("Area")
	var colliders: Array[Area2D] = area.get_overlapping_areas()
	for collider: Area2D in colliders:
		if collider.is_in_group("gate_io"):
			return {
				"collider": collider,
				"connector": connector
			}
	return {
		"collider": null,
		"connector": null
	}

func check_disconnect() -> void:
	var input_collision: Dictionary = self.check_for_gate_io_collision(connectorIn)
	var output_collision: Dictionary = self.check_for_gate_io_collision(connectorOut)

	if input_connection != null and input_collision.collider == null:
		input_connection.remove_connector(self)
		input_connection = null

	if output_connection != null and output_collision.collider == null:
		output_connection.remove_connector(self)
		output_connection = null

func update_led(state_override: bool, state: bool) -> void:
	if !state_override:
		state = self.evaluate()
	led.material.set_shader_parameter("enabled", state)

func propagate(visited: Dictionary = {}) -> void:
	if self in visited:
		return
	visited[self] = true

	if output_connection != null:
		output_connection.update_led(false, false)
		output_connection.propagate_forward(visited)

func reset_position() -> void:
	# called by reset() in the circuit script
	# to reset the static wired io

	connectorIn.position = Vector2(0, 8)
	connectorOut.position = Vector2(100, 8)
	self.update_wire()