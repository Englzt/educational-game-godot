class_name MonsterStat extends Resource

@export var attack_cooldown: float = 1.0
@export var min_health: int = 50
@export var max_health: int = 255
var health: int = 0 # to be set by the game logic
@export var attack_damage: int = 10

@export var texture: Texture2D
@export var texture_scale: Vector2 = Vector2(1, 1)

func set_random_health() -> int:
    health = randi_range(min_health, max_health)
    return health