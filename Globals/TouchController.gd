extends Node

var active_touches: Dictionary[int, Dictionary] = {}

var enabled: bool = true

var last_dragged_panel: Node = null

func _ready() -> void:
	SignalBus.enable_draggable_nodes.connect(enable_draggable_nodes)

func _input(event: InputEvent) -> void:
	if !enabled:
		return

	if event is InputEventScreenTouch:
		if event.pressed:
			active_touches[event.index] = {
				"start_pos": event.position,
				"dragged_panel": get_panel_under_touch(event.position)
			}
			SignalBus.draggable_node_picked.emit(active_touches[event.index]["dragged_panel"])
		else:
			if not active_touches.has(event.index):
				return
			last_dragged_panel = active_touches[event.index]["dragged_panel"]
			SignalBus.draggable_node_dropped.emit(last_dragged_panel)
			active_touches.erase(event.index)

	elif event is InputEventScreenDrag:
		if event.index in active_touches:
			var touch_data := active_touches[event.index]
			if touch_data["dragged_panel"]:
				var panel: Node = touch_data["dragged_panel"]
				var parent: Node = panel.get_parent()

				@warning_ignore("untyped_declaration")
				var local_relative = parent.to_local(parent.to_global(panel.position) + event.relative) - panel.position
				
				panel.position += local_relative
				panel.move()

func is_point_in_rotated_sprite(sprite: Sprite2D, point: Vector2) -> bool:
	var tex_size: Vector2 = sprite.get_texture().get_size()
	if sprite.name.contains("Connector") or sprite.name == "DragPoint":
		return sprite.global_position.distance_to(point) < tex_size.x
	else:
		var global_xform: Transform2D = sprite.get_global_transform()
		var local_point := global_xform.affine_inverse() * point
		return local_point.x >= 0 and local_point.y >= 0 and local_point.x < tex_size.x and local_point.y < tex_size.y

func get_panel_under_touch(position: Vector2) -> Node:
	if !enabled:
		return null

	var first: Node = null
	for draggable: Sprite2D in get_tree().get_nodes_in_group("draggable"):
		if is_point_in_rotated_sprite(draggable, position):
			# prints("Draggable Node Found: ", draggable.name)
			if draggable.name.contains("Connector"): # make sure that connectors are picked before gates
				return draggable
			if first == null:
				first = draggable

	if first:
		return first
			
	return null

func register_draggable_node(panel: Draggable_Node) -> void:
	if !enabled:
		return

	if panel:
		panel.add_to_group("draggable")

func enable_draggable_nodes(value: bool) -> void:
	enabled = value

func get_last_dragged_panel() -> Node:
	if last_dragged_panel:
		return last_dragged_panel
	else:
		return null
