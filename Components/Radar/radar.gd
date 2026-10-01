extends Node2D

@onready var mask: Sprite2D = %Mask
@onready var background: Sprite2D = %Background
@onready var foreground: Sprite2D = %Foreground

@onready var gun_sprite: Sprite2D = %Gun
@onready var round_shot_sprite: Sprite2D = %RoundShot

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var uboot_animation_player: AnimationPlayer = %AnimationPlayerUboot
@onready var gun_animation_player: AnimationPlayer = %AnimationPlayerGun

@onready var current_monster: MonsterInstance = %Monster

@onready var submarine: Sprite2D = %Submarine
@onready var foam_particles: GPUParticles2D = %FoamParticles

@onready var monster_timer: Timer = %MonsterTimer
@onready var timer_label: Label = %LabelTimer
@onready var attack_indicator: Node2D = %AttackIndicator

var scroll_speed := Vector2(30, 0)

var is_shooting: bool = false

@onready var layers: Array = [background, foreground]
var layer_scales: Array = [0.5, 1.0]

func _ready() -> void:
	foam_particles.emitting = true
	SignalBus.binary_submitted.connect(shoot)
	SignalBus.monster_defeated.connect(on_monster_defeated)

func _process(delta: float) -> void:
	self.move_background(delta)
	if current_monster.stats != null:
		timer_label.text = str(int(monster_timer.time_left))
	
func move_background(delta: float) -> void:
	for i in layers.size():
		var current_size: Rect2 = layers[i].get_region_rect()
		current_size.size.x += scroll_speed.x * layer_scales[i] * delta * 0.5
		layers[i].set_region_rect(current_size)

func reset() -> void:

	submarine.modulate = Color(1, 1, 1, 1)

	var target_rect0: Rect2 = layers[0].get_region_rect()
	var target_rect1: Rect2 = layers[1].get_region_rect()

	foam_particles.speed_scale = 3.0
	
	uboot_animation_player.stop()
	uboot_animation_player.play("propellor_animation", true, 5.0)
	var tween: Tween = create_tween()
	tween.tween_property(layers[0], "region_rect", target_rect0.grow_side(SIDE_RIGHT, 256 * layer_scales[0] * 2), 1.0).set_ease(Tween.EASE_OUT)
	tween.parallel()
	tween.tween_property(layers[1], "region_rect", target_rect1.grow_side(SIDE_RIGHT, 256 * layer_scales[1] * 2), 1.0).set_ease(Tween.EASE_OUT)

	await tween.finished

	foam_particles.speed_scale = 1.0

	uboot_animation_player.stop()
	uboot_animation_player.play("propellor_animation")

func spawn_monster(monster_stats: MonsterStat) -> void:
	
	if current_monster.stats != null:
		current_monster.stats = null
	
	if animation_player.is_playing():
		animation_player.stop()
		
	attack_indicator.visible = false

	current_monster.setup(monster_stats)
	current_monster.modulate = Color(1, 1, 1, 1)
	current_monster.rotation = 0.0

	current_monster.position = Vector2(-1000, -100)

	await get_tree().create_timer(5).timeout

	# if !animation_player.is_playing():
	# 	await animation_player.animation_finished
	animation_player.play("monster_arrival")
	
	if current_monster.stats == null:
		animation_player.stop()
		return
	
	await animation_player.animation_finished

	monster_timer.wait_time = monster_stats.attack_cooldown + 0.9
	monster_timer.start()	
	attack_indicator.visible = true

	if current_monster.stats == null:
		return

	animation_player.play("monster_idle")

func on_monster_defeated() -> void:
	if current_monster.stats == null:
		return

	attack_indicator.visible = false

	if animation_player.is_playing():
		animation_player.stop()
	animation_player.play("monster_defeated")
	current_monster.stats = null
	await animation_player.animation_finished
	animation_player.stop()
	current_monster.position = Vector2(-1000, -100)

	monster_timer.stop()

func damage_monster(damage: int) -> void:
	if current_monster.stats != null:
		current_monster.damage(damage)
		if current_monster.is_dead():
			animation_player.play("monster_defeated")
			SignalBus.monster_defeated.emit()

func shoot(damage : int) -> void:
	if current_monster.stats == null:
		return

	if is_shooting:
		return

	if damage != current_monster.stats.health:
		return

	is_shooting = true

	var target_rotation: float = gun_sprite.global_position.angle_to_point(current_monster.global_position + Vector2(75, 75))
	var gun_rotation_tween: Tween = create_tween()
	gun_rotation_tween.tween_property(gun_sprite, "rotation", target_rotation, 3.0)

	await gun_rotation_tween.finished

	await get_tree().create_timer(1.5).timeout

	gun_animation_player.play("shoot")
	AudioManager.create_2d_audio_at_location(gun_sprite.global_position, SoundEffect.SOUND_EFFECT_TYPE.CANNON_SHOT)
	await gun_animation_player.animation_finished

	round_shot_sprite.modulate = Color(1, 1, 1, 0)

	self.damage_monster(damage)

	var gun_reset_tween: Tween = create_tween()
	gun_reset_tween.tween_property(gun_sprite, "rotation", 0.0, 3.0)

	await gun_reset_tween.finished

	is_shooting = false

func _on_monster_timer_timeout() -> void:
	if current_monster.stats == null:
		return

	attack_indicator.visible = false
	monster_timer.stop()

	animation_player.play("monster_attack")
	await animation_player.animation_finished
	
	if current_monster.stats == null:
		# in case the monster was defeated during the attack animation
		return

	# SignalBus.ship_damaged.emit(current_monster.stats.attack_damage) ## handled in animation_player by calling send_signal_ship_damaged()

	monster_timer.start()
	attack_indicator.visible = true

	animation_player.play("monster_idle")

func send_signal_ship_damaged() -> void:
	if current_monster.stats == null:
		return
	var damage: int = current_monster.stats.attack_damage
	SignalBus.ship_damaged.emit(damage)
