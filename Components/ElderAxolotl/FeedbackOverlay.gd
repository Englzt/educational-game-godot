class_name FeedbackOverlay
extends Control
	
@export var show_time := 4.0          # Sekunden bis auto-Hide
@onready var axolotl : Sprite2D = $Axolotl
@onready var line     : RichTextLabel = $Line
var tween : Tween
	
func show_line(text:String) -> void:
	visible = true
	line.text = text
	_fade(true)
	
func _fade(fade_in:bool) -> void:
	if tween: tween.kill()
	tween = create_tween()
	modulate.a = 0.0 if fade_in else 1.0
	tween.tween_property(self, "modulate:a", 1.0 if fade_in else 0.0, 0.35)
	if fade_in:
		tween.tween_callback(Callable(self, "_auto_hide"))
		
func _auto_hide() -> void:
	await get_tree().create_timer(show_time).timeout
	_fade(false)
