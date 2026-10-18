class_name HealthGridView
extends Control

## Draws a CombatUnit's health matrix as pointy-top hexes.
## Matrix index (i, j) is used directly as axial (q, r).

signal cell_clicked(unit: CombatUnit, coords: Vector2i)

const HEX_SIZE := 22.0
const SQRT3 := 1.7320508
const NAME_HEIGHT := 24.0
const NO_CELL := Vector2i(0, 0)

const COLOR_ALIVE := Color("#ffffff")
const COLOR_DAMAGED := Color("#454545")
const COLOR_PREVIEW := Color("#ff7a7a")
const COLOR_EDGE := Color("#151515")
const COLOR_TEXT := Color("#e8e0c8")

var unit: CombatUnit
var clickable := false
var action_tiles: Array[BaseActionTile] = [] # action tiles of the currently selected card

var _hover := NO_CELL
var _origin := Vector2.ZERO


func setup(_unit: CombatUnit, _clickable: bool) -> void:
	unit = _unit
	clickable = _clickable
	mouse_filter = Control.MOUSE_FILTER_STOP if clickable else Control.MOUSE_FILTER_IGNORE
	mouse_exited.connect(func() -> void:
		_hover = NO_CELL
		queue_redraw())
	refresh()


func refresh() -> void:
	var min_p := Vector2(INF, INF)
	var max_p := Vector2(-INF, -INF)
	for cell in _cells():
		var p := _axial_to_pixel(cell)
		min_p = min_p.min(p)
		max_p = max_p.max(p)
	if min_p.x == INF:
		min_p = Vector2.ZERO
		max_p = Vector2.ZERO
	var pad := Vector2(HEX_SIZE, HEX_SIZE)
	_origin = -min_p + pad + Vector2(0, NAME_HEIGHT)
	custom_minimum_size = max_p - min_p + pad * 2 + Vector2(0, NAME_HEIGHT)
	queue_redraw()


func _cells() -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	if unit == null:
		return result
	for i in unit.health.size():
		for j in unit.health[i].size():
			var tile: HealthTile = unit.health[i][j]
			if tile and tile.hp >= 0:
				result.append(Vector2i(i, j))
	return result


func _draw() -> void:
	if unit == null:
		return
	var cells := _cells()
	var alive := 0
	#var action_tile_dict := {} # Dict Vector2i->BaseActionTile
	# if _hover != NO_CELL and unit.has_health_tile(_hover):
	# 	# if action_tiles.is_empty():
	# 	# 	action_tile_dict[_hover] = 
	# 	for t in action_tiles:
	# 		action_tile_dict[_hover + t.coords] = true

	for cell in cells:
		var tile: HealthTile = unit.health[cell.x][cell.y]
		if tile.hp > 0:
			alive += 1
		var color := COLOR_ALIVE if tile.hp > 0 else COLOR_DAMAGED
		# if action_tile_dict.has(cell):
		# 	color = color.lerp(COLOR_PREVIEW, 0.65)
		var corners := _corners(_origin + _axial_to_pixel(cell))
		draw_colored_polygon(corners, color)
		corners.append(corners[0])
		draw_polyline(corners, COLOR_EDGE, 2.0)

	for t in action_tiles:
		var cell := _hover + t.coords
		if unit.has_health_tile(cell):
			var corners := _corners(_origin + _axial_to_pixel(cell))
			draw_colored_polygon(corners, Color(t.get_color(),0.65))

	var font := ThemeDB.fallback_font
	var title := "%s  %d/%d" % [unit.display_name, alive, cells.size()]
	draw_string(font, Vector2(0, 16), title, HORIZONTAL_ALIGNMENT_CENTER, size.x, 16, COLOR_TEXT)


func _gui_input(event: InputEvent) -> void:
	if not clickable:
		return
	if event is InputEventMouseMotion:
		var cell := _pixel_to_axial(event.position - _origin)
		if cell != _hover:
			_hover = cell
			queue_redraw()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var cell := _pixel_to_axial(event.position - _origin)
		if unit.has_health_tile(cell):
			accept_event()
			cell_clicked.emit(unit, cell)


func _axial_to_pixel(c: Vector2i) -> Vector2:
	return Vector2(HEX_SIZE * SQRT3 * (c.x + c.y / 2.0), HEX_SIZE * 1.5 * c.y)


func _pixel_to_axial(p: Vector2) -> Vector2i:
	var fq := (SQRT3 / 3.0 * p.x - p.y / 3.0) / HEX_SIZE
	var fr := (2.0 / 3.0 * p.y) / HEX_SIZE
	var fs := -fq - fr
	var q := roundf(fq)
	var r := roundf(fr)
	var s := roundf(fs)
	var dq := absf(q - fq)
	var dr := absf(r - fr)
	var ds := absf(s - fs)
	if dq > dr and dq > ds:
		q = -r - s
	elif dr > ds:
		r = -q - s
	return Vector2i(int(q), int(r))


func _corners(center: Vector2) -> PackedVector2Array:
	var points := PackedVector2Array()
	for k in 6:
		var angle := deg_to_rad(60.0 * k - 30.0)
		points.append(center + Vector2(cos(angle), sin(angle)) * (HEX_SIZE - 1.5))
	return points
