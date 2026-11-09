class_name BackToMenu

## A "Main Menu" button in the top-right corner of a test scene (card and artifact galleries,
## monster test), over everything else in it.

const SIZE := Vector2(220, 56)
const MARGIN := 24.0


static func add_to(scene: Control) -> Button:
	var layer := CanvasLayer.new()
	layer.layer = 10  # above the scene's own scroll areas
	scene.add_child(layer)
	var button := Button.new()
	button.text = "Main Menu"
	button.add_theme_font_size_override("font_size", 26)
	layer.add_child(button)
	button.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	button.offset_left = -SIZE.x - MARGIN
	button.offset_right = -MARGIN
	button.offset_top = MARGIN
	button.offset_bottom = MARGIN + SIZE.y
	button.pressed.connect(func() -> void: scene.get_tree().change_scene_to_file(RunState.MENU_SCENE))
	return button
