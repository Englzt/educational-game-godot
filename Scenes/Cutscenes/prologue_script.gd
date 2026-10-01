extends Node2D

@export var next_scene: SceneLoader.GameScene = SceneLoader.GameScene.MENU

@export var overlay: ColorRect

func _ready() -> void:
	overlay.visible = true

func switch_to_next_scene() -> void:
	SceneLoader.load_scene(self, next_scene)
