extends Sprite2D

enum CheatSheetType {
    RADIO,
    CIRCUIT,
    BINARY
}

@export var type: CheatSheetType = CheatSheetType.RADIO

@export var sheets: Array[Control] = []

func _ready() -> void:
    for sheet in sheets:
        sheet.visible = false

    sheets[type].visible = true