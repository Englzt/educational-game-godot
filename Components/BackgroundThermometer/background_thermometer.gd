extends Node2D

@onready var thermometer: Sprite2D = %ThermometerFill
const MAX_SCALE: float = 11.0
const MIN_SCALE: float = 1.5

func _ready() -> void:
	self.scale_thermometer()

func scale_thermometer() -> void:
	var random_scale: float = randf_range(MIN_SCALE, MAX_SCALE)

	var time: float = 10.0
	var scale_vec: Vector2 = Vector2(1.796, random_scale)
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(thermometer, "scale", scale_vec, time)

	var t: float = (random_scale - MIN_SCALE) / (MAX_SCALE - MIN_SCALE)
	var color: Color = Color(0.2 + 0.8 * t, 0.2, 1.0 - t, 1.0)
	tween.parallel().tween_property(thermometer, "modulate", color, time)

	await tween.finished
	self.scale_thermometer()
