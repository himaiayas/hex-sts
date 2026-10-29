class_name RoomOptionView
extends Control

## One choice in the room draft: the room's shape, doors and type. Click to pick it.
## The door the player enters through is highlighted.

signal chosen(room: MapRoom)

const OPTION_SIZE := Vector2(300, 340)
const HEX := 90.0

const COLOR_BG := Color("#14171f")
const COLOR_BORDER := Color("#3b4152")
const COLOR_BORDER_HOVER := Color("#ffd45a")
const COLOR_TITLE := Color.WHITE
const COLOR_SUBTITLE := Color("#8d93a5")

var room: MapRoom
var entry_door := -1

var _hover := false


func setup(_room: MapRoom, _entry_door: int) -> void:
	room = _room
	entry_door = _entry_door
	custom_minimum_size = OPTION_SIZE
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	mouse_entered.connect(func() -> void:
		_hover = true
		queue_redraw())
	mouse_exited.connect(func() -> void:
		_hover = false
		queue_redraw())


func _draw() -> void:
	if room == null:
		return
	draw_rect(Rect2(Vector2.ZERO, size), COLOR_BG)
	draw_rect(Rect2(Vector2.ZERO, size), COLOR_BORDER_HOVER if _hover else COLOR_BORDER, false, 2.0)
	RoomDraw.draw_room(self, Vector2(size.x / 2, 150), HEX, room, RoomDraw.COLOR_ROOM, entry_door)
	var font := ThemeDB.fallback_font
	draw_string(font, Vector2(0, 285), room.display_name(), HORIZONTAL_ALIGNMENT_CENTER, size.x, 26, COLOR_TITLE)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		accept_event()
		chosen.emit(room)
