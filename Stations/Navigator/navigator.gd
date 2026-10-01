extends Node2D

signal navigator_travelled(nav_index: int, target_node: int, cost: int)
signal navigator_end_reached(nav_index: int)
signal navigator_invalid_move(nav_index:int)

@warning_ignore("unused_signal")
signal travel_finished(index: int)

@export var nav_index: int = -1

@onready var travel_button: TextureButton = %ButtonTravel
@onready var path_cost_label_settings: Resource = preload("uid://bj6vpineko30e")

@onready var travel_penalty_container: HBoxContainer = %TravelPenaltyContainer
@onready var travel_penalty_label: Label = %LabelTravelPenalty

@onready var graph_nodes: Array[Area2D] = [
	%GraphNode0,
	%GraphNode1,
	%GraphNode2,
	%GraphNode3,
	%GraphNode4,
	%GraphNode5,
	%GraphNode6,
	%GraphNode7,
	%GraphNode8,
	%GraphNode9,
	%GraphNode10
]

var paths: Dictionary = {
	0 : [{ "to": 1, "cost": 5 }],
	1 : [{ "to": 2, "cost": 4 }, { "to": 3, "cost": 6 }],
	2 : [{ "to": 3, "cost": 6 }],
	3 : [{ "to": 4, "cost": 2 }],
	4 : [{ "to": 5, "cost": 3 }, { "to": 6, "cost": 4 }, { "to": 7, "cost": 3 }],
	5 : [{ "to": 6, "cost": 3 }, { "to": 8, "cost": 2 }],
	6 : [{ "to": 7, "cost": 2 }, { "to": 8, "cost": 4 }],
	7 : [{ "to": 8, "cost": 3 }, {"to": 10, "cost": 18 }],
	8 : [{ "to": 9, "cost": 1 }],
	9 : [],
	10: [{"to": 9, "cost": 5}]
}

var start_node: int = 0
var end_node: int = 9
var current_node: int = start_node
var selected_node: int = -1

var can_travel: bool = false

var travel_penalty_active: bool = true
var travel_penalty: int = 5

@export var color_visited: Color = Color("#ff4d3c")
@export var color_current: Color = Color("#4179ff")
@export var color_selected: Color = Color("#64ff64")
@export var color_selected_deactivated: Color = Color("#c00300")

func _ready() -> void: 

	SignalBus.round_completed.connect(self.on_round_completed)
	SignalBus.round_started.connect(self.new_round)

	self.create_paths()
	# prints(self.shortest_path(start_node, end_node))
	self.new_round()

func randomize_path_costs() -> void:

	for path: Line2D in %Paths.get_children():
		path.queue_free()

	for node_index: int in paths.keys():
		for next_node_dict: Dictionary in paths[node_index]:
			var cost: int = randi() % 10 + 1
			next_node_dict["cost"] = cost

	self.create_paths()
	prints("Path costs randomized.", self.shortest_path(start_node, end_node))

func create_paths() -> void:
	var created_paths := []

	for node_index: int in paths.keys():
		var node: Area2D = graph_nodes[node_index]

		for next_node_dict: Dictionary in paths[node_index]:
			var next_node_index: int = next_node_dict["to"]

			var path_pair := [min(node_index, next_node_index), max(node_index, next_node_index)]
			if path_pair in created_paths:
				continue

			created_paths.append(path_pair)

			var next_node_cost: int = next_node_dict["cost"]
			var next_node: Area2D = graph_nodes[next_node_index]

			var line: Line2D = Line2D.new()
			line.width = 15
			line.set_points([node.position, next_node.position])
			line.set_name(str(node_index) + "_" + str(next_node_index))
			%Paths.add_child(line)

			var label: Label = Label.new()
			label.text = str(next_node_cost) + "⚡"
			label.position = (node.position + next_node.position) / 2 - Vector2(32, 32)

			label.set_label_settings(path_cost_label_settings)
			line.add_child(label)

func path_exists(from: int, to: int) -> bool:
	for connection: Dictionary in paths.get(from, []):
		if connection["to"] == to:
			return true
	for connection: Dictionary in paths.get(to, []):
		if connection["to"] == from:
			return true
	return false

func get_path_cost(from: int, to: int) -> int:
	for connection: Dictionary in paths.get(from, []):
		if connection["to"] == to:
			return connection["cost"]
	for connection: Dictionary in paths.get(to, []):
		if connection["to"] == from:
			return connection["cost"]
	return -1

func _on_grid_node_input(_viewport: Viewport, event: InputEvent, _shape_idx: int, node_index: int) -> void:
	if event is InputEventScreenTouch and event.pressed:
		if not can_travel:
			return
		self.highlight_graph_node(node_index)
		prints(paths[node_index])

func highlight_graph_node(node_index: int) -> void:
	if graph_nodes[node_index].deactivated:
		navigator_invalid_move.emit(nav_index)
		return
		
	if not is_node_reachable(node_index):
		return

	for node: Area2D in graph_nodes:
		node.highlight(false)

	travel_penalty_active = false

	if graph_nodes[node_index].deactivated:
		travel_penalty_active = true
		graph_nodes[node_index].highlight(true, color_selected_deactivated, true)
	else:
		graph_nodes[node_index].highlight(true, color_selected)

	travel_penalty_label.text = "+" + str(travel_penalty)
	travel_penalty_container.visible = travel_penalty_active

	selected_node = node_index
	travel_button.set_disabled(!self.is_node_reachable(node_index))

func is_node_reachable(node_index: int) -> bool:
	if node_index == -1:
		return false

	if node_index == current_node:
		return false

	if path_exists(current_node, node_index):
		return true

	return false

func shortest_path(from: int, to: int) -> Dictionary:
	# Initialize distances with infinity for all nodes
	var distances: Dictionary = {}
	var previous: Dictionary = {}
	var unvisited: Array[int] = []
	
	# Initialize all nodes
	for node: int in paths.keys():
		distances[node] = INF
		previous[node] = null
		unvisited.append(node)
	
	# Distance to start node is 0
	distances[from] = 0
	
	var current: int = -1

	while unvisited.size() > 0:
		# Find unvisited node with minimum distance
		current = -1
		var min_distance: float = INF
		
		for node: int in unvisited:
			if distances[node] < min_distance:
				min_distance = distances[node]
				current = node
		
		# If we can't reach any more nodes, break
		if current == -1 or distances[current] == INF:
			break
		
		# Remove current from unvisited
		unvisited.erase(current)
		
		# If we reached the target, we can stop
		if current == to:
			break
		
		# Check all neighbors of current node
		if paths.has(current):
			for edge: Dictionary in paths[current]:
				var neighbor: int = edge["to"]
				var cost: int = edge["cost"]
				
				# Calculate new distance through current node
				var new_distance: float = distances[current] + cost
				
				# If we found a shorter path, update it
				if new_distance < distances[neighbor]:
					distances[neighbor] = new_distance
					previous[neighbor] = current
	
	# If target is unreachable
	if distances[to] == INF:
		return {"path": [], "cost": -1}
	
	# Reconstruct path by backtracking
	var path: Array[int] = []
	current = to
	
	while previous[current] != null:
		path.push_front(current)
		current = previous[current]
	path.push_front(current)  # Add the start node
	
	return {"path": path, "cost": int(distances[to])}

func _on_button_travel_pressed() -> void:
	var cost: int = self.get_path_cost(current_node, selected_node)
	if travel_penalty_active:
		cost += travel_penalty

	SignalBus.graph_node_travelled.emit(selected_node, cost)
	navigator_travelled.emit(nav_index, selected_node, cost) # für Bonuslevel
	graph_nodes[current_node].deactivate(color_visited)
	current_node = selected_node
	self.new_round()

func new_round() -> void:
	for node: Area2D in graph_nodes:
		if node.deactivated:
			continue
		node.highlight(false)

	travel_penalty_container.visible = false	

	graph_nodes[current_node].deactivate(color_current)
	selected_node = -1
	can_travel = false
	travel_button.set_disabled(true)

	if current_node == end_node:
		SignalBus.graph_node_end_reached.emit()
		navigator_end_reached.emit(nav_index) # Bonuslevel

func on_round_completed() -> void:
	can_travel = true
	# print_debug("Navigator", nav_index, "→ can_travel =", can_travel)
