extends Node

## Fullscreen (autoload "Display"): on by default, toggled by F11 or Alt+Enter anywhere, or the
## Options checkbox; remembered in AudioSettings.PATH (user://settings.cfg) under [display].

const SETTINGS_PATH := AudioSettings.PATH

var fullscreen := true:
	set(value):
		fullscreen = value
		_apply()
		var settings := ConfigFile.new()
		settings.load(SETTINGS_PATH)  # keep the other settings
		settings.set_value("display", "fullscreen", fullscreen)
		settings.save(SETTINGS_PATH)

signal fullscreen_changed(on: bool)


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var settings := ConfigFile.new()
	if settings.load(SETTINGS_PATH) == OK:
		fullscreen = settings.get_value("display", "fullscreen", true)
	_apply()


func _unhandled_key_input(event: InputEvent) -> void:
	var key := event as InputEventKey
	if key == null or not key.pressed or key.echo:
		return
	if key.keycode == KEY_F11 or (key.keycode == KEY_ENTER and key.alt_pressed):
		fullscreen = not fullscreen
		get_viewport().set_input_as_handled()


func _apply() -> void:
	if not is_inside_tree():
		return
	if fullscreen:
		if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	elif DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_WINDOWED:
		# Back to the project's window size (window_*_override, smaller than the screen: a window as
		# big as the screen would count as fullscreen again), centred above the taskbar.
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		_center_window()
	fullscreen_changed.emit(fullscreen)


## Centres the window in the usable screen area, a couple of frames after leaving fullscreen
## (the system applies the mode change late).
func _center_window() -> void:
	for i in 2:
		await get_tree().process_frame
	if fullscreen:
		return  # switched back meanwhile
	var usable := DisplayServer.screen_get_usable_rect()
	DisplayServer.window_set_position(usable.position + (usable.size - DisplayServer.window_get_size()) / 2)
