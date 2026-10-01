extends Button

@onready var led: TextureRect = %LED

var index: int = -1

signal led_pressed(index: int)

func _on_pressed() -> void:
	led_pressed.emit(index)

func light_up(color: Color) -> void:
	led.modulate = color
	await get_tree().create_timer(0.4).timeout
	led.modulate = Color.WHITE
