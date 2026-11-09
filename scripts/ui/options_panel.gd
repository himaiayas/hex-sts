class_name OptionsPanel
extends PanelContainer

## The Options page, shared by the main menu and the in-game menu: Music and Sound Effects volume
## (saved by AudioSettings). Emits back_pressed when the player is done.

signal back_pressed

const COLOR_BG := Color("#151820")
const COLOR_BORDER := Color("#3a4152")



func _init() -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = COLOR_BG
	style.border_color = COLOR_BORDER
	style.set_border_width_all(2)
	style.set_corner_radius_all(12)
	style.set_content_margin_all(40)
	add_theme_stylebox_override("panel", style)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 28)
	add_child(box)

	var title := Label.new()
	title.text = "Options"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 44)
	box.add_child(title)

	box.add_child(_volume_row("Music", Music.volume, func(level: float) -> void: Music.volume = level))
	box.add_child(_volume_row("Sound Effects", Sfx.volume, func(level: float) -> void: Sfx.volume = level))
	var fullscreen := CheckButton.new()
	fullscreen.text = "Fullscreen (F11)"
	fullscreen.button_pressed = Display.fullscreen
	fullscreen.add_theme_font_size_override("font_size", 28)
	fullscreen.toggled.connect(func(on: bool) -> void: Display.fullscreen = on)
	Display.fullscreen_changed.connect(fullscreen.set_pressed_no_signal)  # F11 too; disconnects when freed
	box.add_child(fullscreen)

	var back := Button.new()
	back.text = "Back"
	back.custom_minimum_size = Vector2(240, 56)
	back.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	back.add_theme_font_size_override("font_size", 28)
	back.pressed.connect(back_pressed.emit)
	box.add_child(back)


## Label, 0-100% slider and its value. set_level gets 0 to 1 as the slider moves.
func _volume_row(text: String, level: float, set_level: Callable) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 20)
	var label := Label.new()
	label.text = text
	label.custom_minimum_size.x = 220
	label.add_theme_font_size_override("font_size", 28)
	row.add_child(label)
	var slider := HSlider.new()
	slider.min_value = 0
	slider.max_value = 100
	slider.step = 1
	slider.value = roundi(level * 100)
	slider.custom_minimum_size = Vector2(360, 40)
	slider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(slider)
	var value_label := Label.new()
	value_label.custom_minimum_size.x = 80
	value_label.add_theme_font_size_override("font_size", 28)
	value_label.text = "%d%%" % roundi(slider.value)
	row.add_child(value_label)
	slider.value_changed.connect(func(value: float) -> void:
		set_level.call(value / 100.0)
		value_label.text = "%d%%" % roundi(value))
	slider.drag_ended.connect(func(_changed: bool) -> void: Sfx.play("click"))  # hear the new level
	return row
