class_name MapView
extends Control

## Draws the map (rooms, buildable spots, player) and reports clicked cells.
## Hovering a room or spot shows the path there (MapState.plan_to) and how many steps it costs,
## in red when there aren't enough steps left.

signal cell_clicked(cell: Vector2i)

const HEX := 64.0
const NO_CELL := Vector2i(999999, 999999)
const CAMERA_SPEED := 4.0
const STEP_TIME := 0.14

const COLOR_ROOM_HOVER := Color("#343a49")
const COLOR_FRONTIER := Color("#2a2f3b")
const COLOR_FRONTIER_HOVER := Color("#1a1d25")
const COLOR_FRONTIER_TEXT := Color("#4a5163")
const COLOR_CURRENT := Color("#ffd45a")
const COLOR_PLAYER := Color("#ffd45a")
const COLOR_COST := Color("#c9cdd8")
const COLOR_PATH := Color("#ffd45a")
const COLOR_TOO_FAR := Color("#ff6b6b")
const COLOR_TOOLTIP_BG := Color("#0b0d12")
const PATH_WIDTH := 6.0
const PATH_DOT := 7.0  # radius of the dot on each room the path enters
const COST_FONT_SIZE := 26
const FOOTSTEP := preload("res://assets/icons/footstep.png")
const FOOTSTEP_SIZE := 26.0

var map: MapState
var token_pos := Vector2.ZERO  # player position in map pixels

var _hover := NO_CELL
var _camera := Vector2.ZERO


func setup(_map: MapState) -> void:
	map = _map
	token_pos = RoomDraw.axial_to_pixel(map.current, HEX)
	_camera = _camera_target()
	queue_redraw()


## Moves the player token through each room in order. Await it to know when it arrives.
func animate_path(path: Array[Vector2i]) -> void:
	for cell in path:
		var tween := create_tween()
		tween.tween_property(self, "token_pos", RoomDraw.axial_to_pixel(cell, HEX), STEP_TIME)
		await tween.finished


func _process(delta: float) -> void:
	if map == null:
		return
	_camera = _camera.lerp(_camera_target(), 1.0 - exp(-CAMERA_SPEED * delta))
	queue_redraw()


## Keeps the explored area centred.
func _camera_target() -> Vector2:
	var total := Vector2.ZERO
	for cell in map.rooms:
		total += RoomDraw.axial_to_pixel(cell, HEX)
	return -total / map.rooms.size()


func _origin() -> Vector2:
	return size / 2 + _camera


func _draw() -> void:
	if map == null:
		return
	var origin := _origin()
	var font := ThemeDB.fallback_font

	for cell in map.frontier():
		var center := origin + RoomDraw.axial_to_pixel(cell, HEX)
		var points := RoomDraw.corners(center, HEX * RoomDraw.INSET)
		if cell == _hover:
			draw_colored_polygon(points, COLOR_FRONTIER_HOVER)
		points.append(points[0])
		draw_polyline(points, COLOR_FRONTIER, 2.0)
		draw_string(font, center + Vector2(-20, 12), "?", HORIZONTAL_ALIGNMENT_CENTER, 40, 32, COLOR_FRONTIER_TEXT)

	for cell in map.rooms:
		var center := origin + RoomDraw.axial_to_pixel(cell, HEX)
		var fill := COLOR_ROOM_HOVER if cell == _hover else RoomDraw.COLOR_ROOM
		RoomDraw.draw_room(self, center, HEX, map.rooms[cell], fill)

	var current := RoomDraw.corners(origin + RoomDraw.axial_to_pixel(map.current, HEX), HEX * RoomDraw.INSET)
	current.append(current[0])
	draw_polyline(current, COLOR_CURRENT, 3.0)
	_draw_hover_path(origin, font)


## The path from the current room to the hovered room or spot, with its step cost at the end.
## Hidden while the token is still moving.
func _draw_hover_path(origin: Vector2, font: Font) -> void:
	if _hover == NO_CELL or token_pos != RoomDraw.axial_to_pixel(map.current, HEX):
		return
	var plan := map.plan_to(_hover)
	if plan.is_empty():
		return
	var color := COLOR_TOO_FAR if plan.cost > map.steps else COLOR_PATH
	var points := PackedVector2Array([origin + RoomDraw.axial_to_pixel(map.current, HEX)])
	for cell: Vector2i in plan.path:
		points.append(origin + RoomDraw.axial_to_pixel(cell, HEX))
	if plan.build:
		points.append(origin + RoomDraw.axial_to_pixel(plan.target, HEX))
	draw_polyline(points, Color(color, 0.8), PATH_WIDTH, true)
	for i in range(1, points.size()):
		draw_circle(points[i], PATH_DOT, color)
	var end := points[points.size() - 1]
	var text := "%d" % plan.cost
	var text_width := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, COST_FONT_SIZE).x
	var box_size := Vector2(FOOTSTEP_SIZE + 6 + text_width + 16, 34)
	var box := Rect2(end + Vector2(-box_size.x / 2, -HEX * 0.55 - 30), box_size)
	draw_rect(box, Color(COLOR_TOOLTIP_BG, 0.85))
	draw_texture_rect(FOOTSTEP, Rect2(box.position + Vector2(8, 4), Vector2.ONE * FOOTSTEP_SIZE), false, color)
	draw_string(font, box.position + Vector2(8 + FOOTSTEP_SIZE + 6, 27), text, HORIZONTAL_ALIGNMENT_LEFT, -1,
		COST_FONT_SIZE, color)


func _gui_input(event: InputEvent) -> void:
	if map == null:
		return
	if event is InputEventMouseMotion:
		_hover = RoomDraw.pixel_to_axial(event.position - _origin(), HEX)
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		accept_event()
		cell_clicked.emit(RoomDraw.pixel_to_axial(event.position - _origin(), HEX))


func _notification(what: int) -> void:
	if what == NOTIFICATION_MOUSE_EXIT:
		_hover = NO_CELL
