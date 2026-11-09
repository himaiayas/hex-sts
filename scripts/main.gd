extends Control

## Main menu: Continue (only with a saved run), New Run, Options, Credits, Quit.

@onready var _buttons: VBoxContainer = $Menu

var _options: OptionsPanel
var _confirm_new_run: PanelContainer


func _ready() -> void:
	if SaveGame.exists():
		_add_button("Continue", _on_continue_pressed)
	_add_button("New Run", _on_new_run_pressed)
	_add_button("Options", _on_options_pressed)
	_add_button("Credits", _on_credits_toggled)
	_add_button("Quit", get_tree().quit)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)
	_options = OptionsPanel.new()
	_options.back_pressed.connect(_on_options_back)
	_options.hide()
	center.add_child(_options)

	_confirm_new_run = _new_run_panel()
	_confirm_new_run.hide()
	center.add_child(_confirm_new_run)


func _add_button(text: String, action: Callable) -> void:
	var button := Button.new()
	button.text = text
	button.alignment = HORIZONTAL_ALIGNMENT_RIGHT
	button.pressed.connect(action)
	_buttons.add_child(button)


func _on_continue_pressed() -> void:
	if not RunState.continue_run():
		_start_new_run()  # the save couldn't be read


func _on_new_run_pressed() -> void:
	if SaveGame.exists():
		_buttons.hide()
		_confirm_new_run.show()
	else:
		_start_new_run()


func _start_new_run() -> void:
	SaveGame.delete()  # start_new_run() leaves the save alone (test scenes call it too)
	RunState.start_new_run()
	get_tree().change_scene_to_file(RunState.MAP_SCENE)


func _on_options_pressed() -> void:
	_buttons.hide()
	_options.show()


func _on_options_back() -> void:
	_options.hide()
	_buttons.show()


func _on_credits_toggled() -> void:
	$Credits.visible = not $Credits.visible
	$Logo.visible = not $Credits.visible
	_buttons.visible = not $Credits.visible


## Asks before New Run replaces the saved run. Looks like the Options page.
func _new_run_panel() -> PanelContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _options.get_theme_stylebox("panel"))

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 28)
	panel.add_child(box)

	var title := Label.new()
	title.text = "New Run"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 44)
	box.add_child(title)

	var text := Label.new()
	text.text = "Start a new run? Your saved run will be lost."
	text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	text.add_theme_font_size_override("font_size", 28)
	box.add_child(text)

	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 20)
	box.add_child(row)
	for choice in [["New Run", _start_new_run], ["Cancel", _on_new_run_cancelled]]:
		var button := Button.new()
		button.text = choice[0]
		button.custom_minimum_size = Vector2(240, 56)
		button.add_theme_font_size_override("font_size", 28)
		button.pressed.connect(choice[1])
		row.add_child(button)
	return panel


func _on_new_run_cancelled() -> void:
	_confirm_new_run.hide()
	_buttons.show()
