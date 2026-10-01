extends Node2D

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var sprite : Sprite2D      = $Sprite2D
@onready var explosion : Sprite2D   = $Explosion
@onready var rocket : Sprite2D      = $RocketShoot

var health: int = 1
signal explosion_finished

func set_health(value: int) -> void:
	health = value

func explode() -> void:
	anim.play("asteroid")
	await anim.animation_finished
	#hide()
	emit_signal("explosion_finished")                            

func reset_asteroid(new_hp:int) -> void:
	health = new_hp
	explosion.visible = false
	rocket.visible    = false
	sprite.visible    = true
	show()   
