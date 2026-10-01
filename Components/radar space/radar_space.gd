extends Node2D

@onready var mask: Sprite2D = %Mask
@onready var background: Sprite2D = %Background
@onready var foreground: Sprite2D = %Foreground

@onready var animation_player: AnimationPlayer = %AnimationPlayer

# const MONSTER_SCENE: PackedScene = preload("uid://cutxlwsog5pwu")

@onready var current_monster: = %Mask/Asteroid1

var scroll_speed := Vector2(30, 0)

@onready var layers: Array = [background, foreground]
var layer_scales: Array = [0.5, 1.0]

func _ready() -> void:
	SignalBus.monster_defeated.connect(self.on_monster_defeated)

func _process(delta: float) -> void:
	self.move_background(delta)
	
func move_background(delta: float) -> void:
	for i in layers.size():
		var current_size: Rect2 = layers[i].get_region_rect()
		current_size.size.x += scroll_speed.x * layer_scales[i] * delta * 0.5
		layers[i].set_region_rect(current_size)

func reset() -> void:
	for i in layers.size():
		layers[i].set_region_rect(Rect2(0, 0, 256, 256))

func spawn_monster(monster_stats: MonsterStat) -> void:
	if current_monster.stats != null:
		current_monster.stats = null

	# current_monster = MONSTER_SCENE.instantiate()
	# current_monster.name = "Monster"
	# mask.add_child(current_monster)
	current_monster.setup(monster_stats)

	current_monster.position = Vector2(-1000, -100)

	animation_player.play("monster_arrival")
	await animation_player.animation_finished

	animation_player.play("monster_idle")

func on_monster_defeated() -> void:
	if current_monster.stats == null:
		return
	if animation_player.is_playing():
		animation_player.stop()
	animation_player.play("monster_defeated")
	current_monster.stats = null

#func damage_monster(damage: int) -> void:
	#if current_monster.stats != null:
		#current_monster.damage(damage)
		#if current_monster.is_dead():
			#animation_player.play("monster_defeated")
			#SignalBus.monster_defeated.emit()
