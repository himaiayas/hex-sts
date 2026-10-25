class_name HealthGridView
extends Control

## Draws a CombatUnit's health matrix as pointy-top hexes.
## Matrix index (i, j) is used directly as axial (q, r).

signal cell_clicked(unit: CombatUnit, coords: Vector2i)

const HEX_SIZE := 22.0
const SQRT3 := 1.7320508
const NAME_HEIGHT := 24.0
const NO_CELL := Vector2i(999999, 999999)  # not (0,0): that's a real cell
const INTENT_ALPHA_MIN := 0.15
const INTENT_ALPHA_MAX := 0.45
const INTENT_PERIOD := 1.4  # seconds per pulse

const COLOR_ALIVE := Color("#ffffff")
const COLOR_DAMAGED := Color("#454545")
const COLOR_PREVIEW := Color("#ff7a7a")
const COLOR_EDGE := Color("#151515")
const COLOR_TEXT := Color("#e8e0c8")
const COLOR_SHIELDED := Color("#a0e5f6")

var unit: CombatUnit
var clickable := false
var action_tiles: Array[BaseActionTile] = [] # action tiles of the currently selected card
var intents: Array = [] # enemy attacks aimed at this grid: [{cell: Vector2i, tiles: Array[BaseActionTile]}]

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
	for cell in unit.health.keys():
		var p := axial_to_pixel(cell)
		min_p = min_p.min(p)
		max_p = max_p.max(p)
	if min_p.x == INF:
		min_p = Vector2.ZERO
		max_p = Vector2.ZERO
	var pad := Vector2(HEX_SIZE, HEX_SIZE)
	_origin = -min_p + pad + Vector2(0, NAME_HEIGHT)
	custom_minimum_size = max_p - min_p + pad * 2 + Vector2(0, NAME_HEIGHT)
	queue_redraw()


func _process(_delta: float) -> void:
	if not intents.is_empty():
		queue_redraw()  # keep the intent pulse animating


func _draw() -> void:
	if unit == null:
		return
	var alive := 0
	var coords := unit.health.keys()
	#var action_tile_dict := {} # Dict Vector2i->BaseActionTile
	# if _hover != NO_CELL and unit.has_health_tile(_hover):
	# 	# if action_tiles.is_empty():
	# 	# 	action_tile_dict[_hover] = 
	# 	for t in action_tiles:
	# 		action_tile_dict[_hover + t.coords] = true

	

	for coord in unit.health.keys():
		var tile: HealthTile = unit.health[coord]
		var color = COLOR_ALIVE
		if tile.hp >= HealthTile.HealthTileEnum.SHIELDED:
			alive += 1
			color = COLOR_SHIELDED
			
		elif tile.hp == HealthTile.HealthTileEnum.UNDAMAGED:
			alive += 1
			if tile.status_effects.size() > 0:
				color = tile.status_effects[0].get_color()
		else:
			color = COLOR_DAMAGED
		# if action_tile_dict.has(cell):
		# 	color = color.lerp(COLOR_PREVIEW, 0.65)
		var corners := hex_corners(_origin + axial_to_pixel(coord), HEX_SIZE - 1.5)
		draw_colored_polygon(corners, color)
		corners.append(corners[0])
		draw_polyline(corners, COLOR_EDGE, 2.0)

	var wave := 0.5 + 0.5 * sin(TAU * Time.get_ticks_msec() / 1000.0 / INTENT_PERIOD)
	var pulse := lerpf(INTENT_ALPHA_MIN, INTENT_ALPHA_MAX, wave)
	for intent in intents:
		for t: BaseActionTile in intent.tiles:
			var cell: Vector2i = intent.cell + t.coords
			if unit.health.has(cell):
				draw_colored_polygon(hex_corners(_origin + axial_to_pixel(cell), HEX_SIZE - 1.5), Color(t.get_color(), pulse))

	for t in action_tiles:
		var cell := _hover + t.coords
		if unit.health.has(cell):
			var corners := hex_corners(_origin + axial_to_pixel(cell), HEX_SIZE - 1.5)
			draw_colored_polygon(corners, Color(t.get_color(),0.65))

	var font := ThemeDB.fallback_font
	var title := "%s  %d/%d" % [unit.display_name, alive, coords.size()]
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
		if unit.health.has(cell):
			accept_event()
			cell_clicked.emit(unit, cell)


static func axial_to_pixel(c: Vector2i, hex_size := HEX_SIZE) -> Vector2:
	return Vector2(hex_size * SQRT3 * (c.x + c.y / 2.0), hex_size * 1.5 * c.y)


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


static func hex_corners(center: Vector2, radius: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	for k in 6:
		var angle := deg_to_rad(60.0 * k - 30.0)
		points.append(center + Vector2(cos(angle), sin(angle)) * radius)
	return points
