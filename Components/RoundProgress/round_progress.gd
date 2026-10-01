extends Control

@onready var binaryLED: TextureRect = %BinaryLED
@onready var mechanicLED: TextureRect = %MechanicLED
@onready var treeLED: TextureRect = %TreeLED

@onready var round_end_label: Label = %RoundEndLabel

var progress: Dictionary = {
	"binary": false,
	"mechanic": false,
	"tree": false
}

func _ready() -> void:
	SignalBus.monster_defeated.connect(self.on_monster_defeated)
	SignalBus.circuit_evaluated.connect(self.on_circuit_evaluated)
	SignalBus.tree_traversed.connect(self.on_tree_traversed)
	SignalBus.round_started.connect(self.reset)

func on_monster_defeated() -> void:#
	progress["binary"] = true
	binaryLED.material.set_shader_parameter("enabled", true)
	self.check_round_end()

func on_circuit_evaluated(solved: bool) -> void:
	progress["mechanic"] = solved
	mechanicLED.material.set_shader_parameter("enabled", solved)
	self.check_round_end()

func on_tree_traversed(_solved: bool) -> void:
	# solved is ignored here, as even a failed traversal counts as progress
	# maybe this entire section should be removed as its only used for energy and not the round progression
	progress["tree"] = true
	treeLED.material.set_shader_parameter("enabled", true)
	self.check_round_end()

func check_round_end() -> void:
	if progress["binary"] and progress["mechanic"] and progress["tree"]:
		round_end_label.visible = true	
		SignalBus.round_completed.emit()

func reset() -> void:
	round_end_label.visible = false	

	progress = {
		"binary": false,
		"mechanic": false,
		"tree": false
	}

	mechanicLED.material.set_shader_parameter("enabled", false)
	treeLED.material.set_shader_parameter("enabled", false)
	binaryLED.material.set_shader_parameter("enabled", false)
