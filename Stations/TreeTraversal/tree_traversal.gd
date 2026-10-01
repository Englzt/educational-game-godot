extends Node2D

enum TraversalMode {
	BREADTH_FIRST,
	DEPTH_FIRST,
}

@export var layout: int = 0
@export var traversal_mode: TraversalMode = TraversalMode.BREADTH_FIRST

@export var layout_overlays: Array[Texture2D]

signal tree_traversed_local(success: bool)

@onready var tree_nodes: Array[Area2D] = [
	%TreeNode0,
	%TreeNode1,
	%TreeNode2,
	%TreeNode3,
	%TreeNode4,
	%TreeNode5,
	%TreeNode6,
	%TreeNode7,
	%TreeNode8,
	%TreeNode9,
	%TreeNode10,
	%TreeNode11,
	%TreeNode12
]

@onready var overlay: Sprite2D = %Overlay
@onready var search_mode_label: Label = %LabelSearchMode
@onready var reward_label: Label = %LabelReward

var graph_node: PackedScene = preload("uid://ba1oupkqi0uca")

var search_index: int = 0

var game_over: bool = false

var max_search_index: int = 0

var layouts: Array

func _ready() -> void:
	var file_path := "res://Stations/TreeTraversal/tree_layouts.json"
	if FileAccess.file_exists(file_path):
		var json_file: FileAccess = FileAccess.open(file_path, FileAccess.READ)
		var json_text: String = json_file.get_as_text()
		var json: JSON = JSON.new()
		var err: int = json.parse(json_text)
		if err == OK:
			layouts = json.get_data()
			#prints("Loaded layouts: ", layouts)
		else:
			layouts = []
		json_file.close()

	self.reset()
	max_search_index = tree_nodes.size() - 1
	SignalBus.tree_traversed.connect(self.on_tree_traversed)

func _on_tree_node_input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int, node_index: int) -> void:
	if event is InputEventScreenTouch and event.pressed:
		if game_over:
			return
		
		self.check_order(node_index, search_index)
		search_index += 1

func check_order(node_index: int, index: int) -> void:
	var node: Area2D = tree_nodes[node_index]

	if traversal_mode == TraversalMode.BREADTH_FIRST:
		if node.breadth_search_index == index:
			self.highlight_tree_node(node_index)
			if index == max_search_index:
				game_over = true
				SignalBus.tree_traversed.emit(true)
				tree_traversed_local.emit(true)
		else:
			node.deactivate(Color("#ff0000"))
			game_over = true
			SignalBus.tree_traversed.emit(false)
			tree_traversed_local.emit(false)


	elif traversal_mode == TraversalMode.DEPTH_FIRST:
		if node.depth_search_index == index:
			self.highlight_tree_node(node_index)
			if index == max_search_index:
				game_over = true
				SignalBus.tree_traversed.emit(true)
				tree_traversed_local.emit(true)
		else:
			node.deactivate(Color("#ff0000"))
			game_over = true
			SignalBus.tree_traversed.emit(false)
			tree_traversed_local.emit(false)

	else:
		node.deactivate(Color("#aaaaaa"))

func highlight_tree_node(node_index: int) -> void:
	tree_nodes[node_index].highlight(true)

func on_tree_traversed(success: bool) -> void:

	if success:
		reward_label.text = "+ " + str(Vars.MINIGAME_HEALTH_AMOUNT) + " HP\n+ " + str(Vars.MINIGAME_ENERGY_AMOUNT) + " ⚡"
	else:
		reward_label.text = "- " + str(Vars.MINIGAME_HEALTH_AMOUNT) + " HP\n- " + str(Vars.MINIGAME_ENERGY_AMOUNT) + " ⚡"
		
	reward_label.modulate = Color(0, 0, 0, 0)
	reward_label.visible = true
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(reward_label, "modulate",  Color.WHITE, 0.5)
	await tween.finished
	await get_tree().create_timer(1.0).timeout
	# reward_label.visible = false
	
func reset() -> void:
	self.load_layout(layout)

	search_mode_label.text = "Unbekannt"
	for node: Area2D in tree_nodes:
		node.deactivated = false
		node.highlight(false)

	reward_label.visible = false
	game_over = false
	search_index = 0	

func set_traversal_mode(mode: TraversalMode) -> void:
	traversal_mode = mode

func show_traversal_mode_string() -> void:
	if traversal_mode == TraversalMode.BREADTH_FIRST:
		search_mode_label.text = "Breitensuche"
	else:
		search_mode_label.text = "Tiefensuche"

func load_layout(layout_index: int) -> void:
	if layout_index < 0 or layout_index >= layouts.size():
		push_error("Invalid layout index: ", layout_index, " - using default layout index 0")
		layout_index = 0

	overlay.texture = layout_overlays[layout_index]

	var layout_data: Dictionary = layouts[layout_index]
	var node_data: Array = layout_data["nodes"]
	for i in range(node_data.size()):
		# prints(node_data[i])
		var tree_node: Area2D = self.get_tree_node_from_name(node_data[i]["name"])
		if tree_node == null:
			push_error("could find tree node with name ", node_data[i]["name"])
			continue
		var pos: Array = node_data[i]["position"]
		tree_node.position = Vector2(pos[0], pos[1])
		tree_node.breadth_search_index = int(node_data[i]["breadth_search_index"])
		tree_node.depth_search_index = int(node_data[i]["depth_search_index"])

func get_tree_node_from_name(tree_node_name: String) -> Area2D:
	for tree_node: Area2D in tree_nodes:
		if tree_node.name == tree_node_name:
			return tree_node
	return null

func pick_random_layout() -> void:
	if layouts.size() == 0:
		layout = 0

	layout = randi_range(0, layouts.size() - 1)
