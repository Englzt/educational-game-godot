class_name Draggable_Node extends Sprite2D

signal DraggableNodeMoved

@export var deletable: bool = true

@onready var size: Vector2 = Vector2.ZERO

func _ready() -> void:
	size = self.get_texture().get_size() * self.scale

func move() -> void:
	DraggableNodeMoved.emit(self)

func get_size() -> Vector2:
	return size

func get_parent_rotation() -> int:
	return get_parent().rotation

func delete_parent() -> void:
	# Deletes the parent node of this draggable node
	# needed because the TouchController only knows the Draggable_Node
	# and the Circuit wants to delete the parent node
	if get_parent() != null:
		if !deletable:
			return
		get_parent().queue_free()
