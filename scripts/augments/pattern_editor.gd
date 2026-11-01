class_name PatternEditor
extends Control

## A card pattern drawn big, with empty cells next to it outlined to click (Expansion Augment).

signal cell_clicked(cell: Vector2i)

const MAX_HEX_SIZE := 34.0
const COLOR_EDGE := Color("#151515")
const COLOR_ORIGIN := Color("#ffffff")
const COLOR_CANDIDATE := Color("#ffd45a")
const COLOR_NEW := Color("#ffd45a")

var action: GridAction
var candidates: Array[Vector2i] = []  # pattern-space cells that can be clicked
var new_cell := Vector2i.MAX  # chosen cell, outlined; its tile is drawn once placed in action

var _hex := MAX_HEX_SIZE
var _origin := Vector2.ZERO
var _hover := Vector2i.MAX


func setup(_action: GridAction, _candidates: Array[Vector2i]) -> void:
	action = _action
	candidates = _candidates
	new_cell = Vector2i.MAX
	_layout()


func _ready() -> void:
	resized.connect(_layout)
	mouse_exited.connect(func() -> void:
		_hover = Vector2i.MAX
		queue_redraw())


## Fit the pattern plus its candidates in the box, centred.
func _layout() -> void:
	if action == null:
		return
	var min_p := Vector2(INF, INF)
	var max_p := Vector2(-INF, -INF)
	for cell in _cells() + candidates:
		var p := HealthGridView.axial_to_pixel(cell, 1.0)
		min_p = min_p.min(p)
		max_p = max_p.max(p)
	var extent := max_p - min_p + Vector2(HealthGridView.SQRT3, 2.0)
	_hex = minf(MAX_HEX_SIZE, minf(size.x / extent.x, size.y / extent.y))
	_origin = size / 2 - (min_p + max_p) / 2 * _hex
	queue_redraw()


func _cells() -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for t in action.tiles:
		cells.append(t.coords + action.anchor)
	return cells


func _draw() -> void:
	if action == null:
		return
	for cell in candidates:
		var corners := HealthGridView.hex_corners(_center(cell), _hex - 2.0)
		if cell == _hover:
			draw_colored_polygon(corners, Color(COLOR_CANDIDATE, 0.35))
		corners.append(corners[0])
		draw_polyline(corners, Color(COLOR_CANDIDATE, 0.8), 2.0)
	for t in action.tiles:
		var cell := t.coords + action.anchor
		var corners := HealthGridView.hex_corners(_center(cell), _hex - 2.0)
		draw_colored_polygon(corners, t.get_color())
		var icon := t.get_icon()
		if icon:
			var half := Vector2.ONE * _hex * 0.55
			draw_texture_rect(icon, Rect2(_center(cell) - half, half * 2.0), false)
		corners.append(corners[0])
		draw_polyline(corners, COLOR_EDGE, 2.0)
	if new_cell != Vector2i.MAX:
		var corners := HealthGridView.hex_corners(_center(new_cell), _hex - 2.0)
		corners.append(corners[0])
		draw_polyline(corners, COLOR_NEW, 4.0)
	var origin := HealthGridView.hex_corners(_center(Vector2i.ZERO), _hex - 2.0)
	origin.append(origin[0])
	draw_polyline(origin, COLOR_ORIGIN, 3.0)


func _center(cell: Vector2i) -> Vector2:
	return _origin + HealthGridView.axial_to_pixel(cell, _hex)


func _gui_input(event: InputEvent) -> void:
	if action == null:
		return
	var cell := HealthGridView.pixel_to_axial(event.position - _origin, _hex) if event is InputEventMouse else Vector2i.MAX
	if event is InputEventMouseMotion and cell != _hover:
		_hover = cell if candidates.has(cell) else Vector2i.MAX
		queue_redraw()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT \
			and candidates.has(cell):
		accept_event()
		cell_clicked.emit(cell)
