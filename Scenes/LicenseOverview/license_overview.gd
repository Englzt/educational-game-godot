extends Control

func _on_button_return_pressed() -> void:
	SceneLoader.load_scene(self, SceneLoader.GameScene.MENU)

func _on_info_meta_clicked(meta:Variant) -> void:
	OS.shell_open(meta)
