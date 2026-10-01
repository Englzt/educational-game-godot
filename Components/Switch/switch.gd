extends Node2D

@onready var switch: Sprite2D = %Switch
@onready var led: Sprite2D = %LED

var state: bool = false
@export var index: int = 0

signal state_changed(state: bool)

func _ready() -> void:
	led.material = led.material.duplicate()

func _on_area_2d_input_event(_viewport:Node, event:InputEvent, _shape_idx:int) -> void:
	if event is InputEventScreenTouch:
		if !event.pressed:
			state = !state
			self.update_sprite()
			if state:
				AudioManager.create_2d_audio_at_location(switch.global_position, SoundEffect.SOUND_EFFECT_TYPE.BUTTON_ON)
			else:
				AudioManager.create_2d_audio_at_location(switch.global_position, SoundEffect.SOUND_EFFECT_TYPE.BUTTON_OFF)

func update_sprite() -> void:
	@warning_ignore("integer_division")
	var tile_size: Vector2 = Vector2(switch.texture.get_width() / 2, switch.texture.get_height())
	switch.set_region_rect(Rect2(tile_size.x * int(state), 0, tile_size.x, tile_size.y))
	led.material.set_shader_parameter("enabled", state)
	state_changed.emit(index, state)

func reset() -> void:
	state = false
	self.update_sprite()
