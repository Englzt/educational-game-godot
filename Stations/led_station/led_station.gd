extends Control
signal next_round_pressed

@onready var led_status := [
	$HBoxContainer/Led1,
	$HBoxContainer/Led2,
	$HBoxContainer/Led3,
]
@onready var next_round_button := $nextButton

func _ready() -> void:
	var callback := Callable(self, "_on_next_button_pressed")
	if next_round_button.is_connected("pressed", callback):
		next_round_button.disconnect("pressed", callback)
	next_round_button.pressed.connect(Callable(self, "_on_next_button_pressed"))

func _on_next_button_pressed() -> void:
	get_viewport().gui_get_focus_owner().release_focus()
	emit_signal("next_round_pressed")

func reset() -> void:
	for led: Node2D in led_status:
		led.texture = preload("res://Assets/Textures/bonuslevel/led_station/led_off_round.svg")
	next_round_button.visible = false

func set_led_on(index: int) -> void:
	led_status[index].texture = preload("res://Assets/Textures/bonuslevel/led_station/led_on_round.svg")

func show_next_round_button() -> void:
	next_round_button.visible = true
	
