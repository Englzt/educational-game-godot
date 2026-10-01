extends Area2D

signal shift_changed(shift: int)

var angle := 0  # in Grad
var shift := 1   # 1–26
var hover := false 

@onready var dial: Sprite2D = %Dial

@export var base_rotation_degrees: float = 90.0
var last_emitted_shift := -1

func _ready() -> void:
	connect("mouse_entered", Callable(self, "_on_mouse_entered"))
	connect("mouse_exited", Callable(self, "_on_mouse_exited"))
func _on_mouse_entered() -> void:
	hover = true

func _on_mouse_exited() -> void:
	hover = false

func _input(event: InputEvent) -> void:
	if hover and event is InputEventMouseMotion and event.button_mask & MOUSE_BUTTON_MASK_LEFT:
		var mouse_pos: Vector2 = get_global_mouse_position()
		var center: Vector2 = global_position
		var dir: float = (mouse_pos - center).angle()
		var deg: float = rad_to_deg(dir) + base_rotation_degrees

		deg = fposmod(deg, 360.0)

		var step: float = 360.0 / 26.0
		var new_shift: int = int((deg + step / 2.0) / step) % 26
				
		if new_shift != shift:
			shift = new_shift
			dial.rotation_degrees = base_rotation_degrees - 90 + shift * step
			emit_signal("shift_changed", shift)			
			AudioManager.create_2d_audio_at_location(self.global_position, SoundEffect.SOUND_EFFECT_TYPE.RADIO_TURN_SOUND_1)
