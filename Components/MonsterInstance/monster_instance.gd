class_name MonsterInstance extends Node2D

@export var stats: MonsterStat

@onready var sprite: Sprite2D = %Sprite2D

func setup(_stats: MonsterStat) -> void:
	if sprite == null:
		# this is needed because of race conditions
		sprite = $Sprite2D
		
	stats = _stats

	sprite.set_texture(stats.texture)
	self.scale = stats.texture_scale

func damage(_damage: int) -> void:
	if stats == null:
		return
		
	stats.health -= _damage
	if stats.health <= 0:
		SignalBus.monster_defeated.emit()
		return
	SignalBus.monster_hit.emit()

func is_dead() -> bool:
	if stats == null:
		return true
	return stats.health <= 0
