extends Control

const SEQUENCE_LENGTH = 5

@onready var led_grid: GridContainer = %GridContainer
@onready var start_button: Button = %StartButton
@onready var reward_label: Label = %LabelReward

@export var led_color: Color = Color.YELLOW
@export var led_color_wrong: Color = Color.RED
@export var led_color_correct: Color = Color.GREEN

var sequence: Array[int] = []
var player_input: Array[int] = []
var accepting_input: bool = false

signal game_finished(success: bool)

func _ready() -> void:
	for i in range(led_grid.get_child_count()):
		var led: Button = led_grid.get_child(i)
		led.index = i
		led.led_pressed.connect(_on_led_pressed)
	
	game_finished.connect(on_game_finished)

func _on_start_pressed() -> void:
	start_button.disabled = true
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(start_button, "modulate", Color(0, 0, 0, 0), 0.2)
	await tween.finished
	await get_tree().create_timer(1.0).timeout
	start_button.visible = false
	generate_sequence()
	await play_sequence()
	player_input.clear()
	accepting_input = true
	

func reset() -> void:
	accepting_input = false
	player_input.clear()
	sequence.clear()
	reward_label.visible = false
	start_button.disabled = false
	start_button.modulate = Color.WHITE
	start_button.visible = true
	for i in range(led_grid.get_child_count()):
		var led: Button = led_grid.get_child(i)
		led.modulate = Color.WHITE

func generate_sequence() -> void:
	sequence.clear()
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.randomize()
	for i in range(SEQUENCE_LENGTH):
		sequence.append(rng.randi_range(0, 8))
	print("Sequenz generiert:", sequence)

func play_sequence() -> void:
	for index in sequence:
		var led: Button = led_grid.get_child(index)
		await led.light_up(led_color)
		await get_tree().create_timer(0.4).timeout

func _on_led_pressed(index: int) -> void:
	if not accepting_input:
		return

	player_input.append(index)
	var led: Button = led_grid.get_child(index)

	for i in range(player_input.size()):
		if player_input[i] != sequence[i]:
			await led.light_up(led_color_wrong)
			game_over()
			return

	await led.light_up(led_color_correct)

	if player_input.size() == sequence.size():
		game_won()

func game_over() -> void:
	accepting_input = false
	# start_button.disabled = false
	game_finished.emit(false)

func game_won() -> void:
	accepting_input = false
	# start_button.disabled = false
	game_finished.emit(true)

func on_game_finished(success: bool) -> void:
	if success:
		reward_label.text = "+ " + str(Vars.MINIGAME_HEALTH_AMOUNT) + " HP\n+ " + str(Vars.MINIGAME_ENERGY_AMOUNT) + " ⚡"
	else:
		reward_label.text = "- " + str(Vars.MINIGAME_HEALTH_AMOUNT) + " HP\n- " + str(Vars.MINIGAME_ENERGY_AMOUNT) + " ⚡"
		
	var tween: Tween = get_tree().create_tween()

	reward_label.modulate = Color(0, 0, 0, 0)
	reward_label.visible = true
	tween.tween_property(reward_label, "modulate", Color.WHITE, 0.5)

	await tween.finished
	await get_tree().create_timer(1.0).timeout