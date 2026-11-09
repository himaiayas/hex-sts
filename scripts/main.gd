extends Control

## Main menu: Continue (only with a saved run), New Run, Options, Credits, Quit.

@onready var _buttons: VBoxContainer = $Menu

var _options: OptionsPanel


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


func _add_button(text: String, action: Callable) -> void:
	var button := Button.new()
	button.text = text
	button.alignment = HORIZONTAL_ALIGNMENT_RIGHT
	button.pressed.connect(action)
	_buttons.add_child(button)


func _on_continue_pressed() -> void:
	if not RunState.continue_run():
		_on_new_run_pressed()  # the save couldn't be read


func _on_new_run_pressed() -> void:
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
