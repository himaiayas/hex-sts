extends Control

## Main menu: Continue (only with a saved run), New Run, Options, Credits, Test Scenes, Quit.
## Test Scenes swaps the list for the card gallery, artifact gallery and monster test (TEST_SCENES).

const TEST_SCENES := [
	["Card Gallery", "res://scenes/tests/card_gallery.tscn"],
	["Artifact Gallery", "res://scenes/tests/artifact_gallery.tscn"],
	["Monster Test", "res://scenes/tests/monster_test.tscn"],
]

@onready var _buttons: VBoxContainer = $Menu

var _options: OptionsPanel
var _confirm_new_run: PanelContainer
var _test_menu: VBoxContainer  # same place and look as _buttons


func _ready() -> void:
	if SaveGame.exists():
		_add_button("Continue", _on_continue_pressed)
	_add_button("New Run", _on_new_run_pressed)
	_add_button("Options", _on_options_pressed)
	_add_button("Credits", _on_credits_toggled)
	_add_button("Test Scenes", _on_test_scenes_toggled)
	_add_button("Quit", get_tree().quit)

	_test_menu = _buttons.duplicate(0) as VBoxContainer  # its position and theme...
	for copy in _test_menu.get_children():  # ...but not its buttons (duplicate copies children)
		_test_menu.remove_child(copy)
		copy.free()
	_test_menu.name = "TestMenu"
	add_child(_test_menu)
	for entry in TEST_SCENES:
		_add_button(entry[0], get_tree().change_scene_to_file.bind(entry[1]), _test_menu)
	_add_button("Back", _on_test_scenes_toggled, _test_menu)
	_test_menu.hide()

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


func _add_button(text: String, action: Callable, to: VBoxContainer = null) -> void:
	var button := Button.new()
	button.text = text
	button.alignment = HORIZONTAL_ALIGNMENT_RIGHT
	button.pressed.connect(action)
	(to if to else _buttons).add_child(button)


func _on_test_scenes_toggled() -> void:
	_test_menu.visible = not _test_menu.visible
	_buttons.visible = not _test_menu.visible


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
