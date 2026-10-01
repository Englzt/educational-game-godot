extends CanvasLayer

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var progress_bar: ProgressBar = %ProgressBar

@warning_ignore("unused_signal") ## signal is emitted in the animation player of loading_screen.tscn
signal safe_to_load

func fade_out() -> void:
	#if animation_player == null:
		#await animation_player.ready
	#animation_player.play("fade_out")
	#await animation_player.animation_finished
	queue_free()

func get_fade_out_duration() -> float:
	return animation_player.get_animation("fade_out").get_length()
