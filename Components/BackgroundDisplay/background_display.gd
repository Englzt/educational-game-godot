extends Node2D

@onready var needle: Sprite2D = %Needle
const MAX_ROTATION: float = 68.0

func _ready() -> void:
	self.rotate_needle()

func rotate_needle() -> void:
	var current_rotation: float = needle.rotation_degrees
	var random_rotation: float = randf_range(-MAX_ROTATION, MAX_ROTATION)

	var time: float = 2.5 + abs(current_rotation - random_rotation) / MAX_ROTATION * 0.5
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(needle, "rotation", deg_to_rad(random_rotation), time)

	await tween.finished
	self.rotate_needle()
