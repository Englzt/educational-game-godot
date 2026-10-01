extends Area2D

@onready var colorrect: ColorRect = %ColorRect
@onready var coll_shape: CollisionShape2D = %CollisionShape2D

@export var breadth_search_index: int = -1
@export var depth_search_index: int = -1

var deactivated: bool = false

func _ready() -> void:
	# prints(self.name, self.position, breadth_search_index, depth_search_index)
	pass

func highlight(enabled: bool) -> void:
	if deactivated:
		return
	if enabled:
		colorrect.set_modulate(Color("#64ff64"))
	else:
		colorrect.set_modulate(Color("#ffffff"))  

func deactivate(new_color: Color = Color("#ff0000")) -> void:
	deactivated = true
	colorrect.set_modulate(new_color)
