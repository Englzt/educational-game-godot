extends Area2D

@onready var sprite: Sprite2D = %Sprite2D

var deactivated: bool = false

@onready var index_label: Label = %LabelIndex
@export var index: int = 0

func _ready() -> void:
	index_label.text = str(index)

func highlight(enabled: bool, color: Color = Color("#64ff64"), override: bool = false) -> void:
	if deactivated and not override:
		sprite.set_modulate("#ff4d3c")
		return
	if enabled:
		sprite.set_modulate(color)
	else:
		sprite.set_modulate(Color("#ffffff"))  

func deactivate(new_color: Color = Color("#ff0000")) -> void:
	deactivated = true
	sprite.set_modulate(new_color)
