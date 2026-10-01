extends Control

@onready var menu_popup: Control = %MenuPopup
@onready var gear_button: TextureButton = %GearButton
@onready var sfx_toggle: CheckButton = %ToggleSFX


@export var current_scene: SceneLoader.GameScene = SceneLoader.GameScene.MENU
@export var debug_panel: Control

func _ready() -> void:
	sfx_toggle.button_pressed = AudioManager.is_sfx_enabled()
	
	if debug_panel:
		debug_panel.visible = false

func _on_gear_pressed() -> void:
	menu_popup.visible = not menu_popup.visible

func _on_restart_pressed() -> void:
	SceneLoader.load_scene(get_parent(), current_scene)

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_main_menu_pressed() -> void:
	SceneLoader.load_scene(get_parent(), SceneLoader.GameScene.MENU)

func _on_toggle_sfx_toggled(toggled_on: bool) -> void:
	AudioManager.set_sfx_enabled(toggled_on)

func _on_gear_button_pressed() -> void:
	
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(gear_button, "rotation", deg_to_rad(45.0), 0.2)

	gear_button.rotation = 0.0

	menu_popup.visible = not menu_popup.visible

func _on_toggle_debug_toggled(toggled_on:bool) -> void:
	if !debug_panel:
		return

	debug_panel.visible = toggled_on
