extends Control

@onready var streamLED: TextureRect = %StreamLED
@onready var radLED: TextureRect = %RadLED
@onready var pressureLED: TextureRect = %PressureLED
@onready var malfuncLED: TextureRect = %MalfuncLED
@onready var minesLED: TextureRect = %MinesLED

@onready var configLabel: Label = %ConfigLabel
@onready var targetSystemLabel: Label = %TargetSystemLabel
@onready var healthLabel: Label = %HealthLabel
@onready var healthBar: ProgressBar = %HealthBar
@onready var energyLabel: Label = %EnergyLabel
@onready var energyBar: ProgressBar = %EnergyBar

signal on_energy_depleted

func set_config_expression(expression: String) -> void:
	configLabel.text = expression

func set_status_effects(effects: Array) -> void:
	var leds: Array = [%StreamLED, %RadLED, %PressureLED, %MalfuncLED, %MinesLED]

	for i in range(effects.size()):
		var enabled: bool = int(effects[i]) == 1
		leds[i].material.set_shader_parameter("enabled", enabled)

func set_target_system(target: String) -> void:
	targetSystemLabel.text = target

func reset() -> void:
	var leds: Array = [%StreamLED, %RadLED, %PressureLED, %MalfuncLED, %MinesLED]
	for led: TextureRect in leds:
		led.material.set_shader_parameter("enabled", false)

	configLabel.text = ""
	targetSystemLabel.text = ""

func set_energy(energy: int) -> void:
	energyLabel.text = str(energy)
	energyBar.value = energy
	if energy <= 0:
		energyBar.value = 0
		on_energy_depleted.emit()

func set_health(health: int) -> void:
	healthLabel.text = str(health)
	healthBar.value = health

func set_initial_energy(energy: int) -> void:
	energyLabel.text = str(energy)
	energyBar.max_value = energy
	energyBar.value = energy

func set_initial_health(health: int) -> void:
	healthLabel.text = str(health)
	healthBar.max_value = health
	healthBar.value = health
