class_name HealthGridView
extends Control

## Draws a CombatUnit's health matrix as pointy-top hexes.
## Matrix index (i, j) is used directly as axial (q, r).

signal cell_clicked(unit: CombatUnit, coords: Vector2i)

const HEX_SIZE := 36.0  # largest hex radius; big grids shrink below it
const MAX_GRID_SIZE := Vector2(460, 420)  # hexes shrink so the grid (without its name) fits in this
const GAP := 2.5  # space between hexes at full size; scales with the hex
const EDGE_WIDTH := 3.0  # tile outline at full size; scales with the hex
const SQRT3 := 1.7320508
const NAME_HEIGHT := 40.0
const NO_CELL := Vector2i(999999, 999999)  # not (0,0): that's a real cell
const INTENT_PERIOD := 1.4  # seconds per pulse
const FLICKER_PERIOD := 0.4  # random targets: faster than intents so the two read differently
const INTENT_FADE := 0.25  # a faded intent's alpha, relative: another enemy is hovered
const PLACED_PERIOD := 1.2  # grid actions already clicked: a slow flash of the whole tile
const PLACED_FILL := 0.6  # strongest fill of that flash
const ICON_SIZE := 40.0  # action icons on targeted tiles (a hex is ~62 wide)
const ICON_ALPHA_MIN := 0.35  # icons blink between these; brighter than the old colour fill
const ICON_ALPHA_MAX := 1.0
const PREVIEW_ALPHA := 0.85  # icons under the cursor (selected card)
const SHIELD_SCALE := 0.55  # shield = a smaller hex inside the tile
const SHIELD_ALPHA := 0.8
const PARTICLE_AMOUNT := 3  # per effect, per tile
const PARTICLE_LIFETIME := 1.8
const PARTICLE_SIZE := 14.0  # px; effect icons are scaled down to this
const PARTICLE_SPEED := Vector2(8, 16)  # min/max px per second, drifting up
const PARTICLE_SPREAD := 18.0  # px from the tile centre where they appear
const POWER_SIZE := 36.0  # power badges, in a row under the grid
const POWER_GAP := 8.0
const FLASH_TIME := 0.3  # seconds per animated change
const FLASH_POP := 0.15  # the flash grows this much bigger than its hex, then shrinks back

const COLOR_ALIVE := Color("#ffffff")
const COLOR_DAMAGED := Color("#454545")
const COLOR_PREVIEW := Color("#ff7a7a")
const COLOR_EDGE := Color("#151515")
const COLOR_TEXT := Color("#e8e0c8")
const COLOR_SHIELDED := Color("#a0e5f6")
const COLOR_PLATE := Color("#8a96a3")
const COLOR_HEAL := Color("#7ee08a")
const PICKED_GREY := 0.45  # how far picked tiles fade from pick_tile's colour toward COLOR_DAMAGED
const COLOR_CANDIDATE := Color("#ffd45a")
const COLOR_NEW := Color("#ffe9a8")

var unit: CombatUnit
var clickable := false
var preview: Dictionary[Vector2i, BaseActionTile] = {} # next grid action of the selected card, rotated: offset from cursor -> tile
var intents: Array = [] # enemy attacks aimed at this grid: [{cell: Vector2i, tiles: Array[BaseActionTile], faded: bool}]
var placed: Array = [] # selected card's grid actions already clicked on this grid: [{cell: Vector2i, tiles: Dictionary[Vector2i, BaseActionTile]}]
var random_target: BaseActionTile = null # selected card's next grid action hits random tiles of a grid: this whole grid flickers
var pick_tile: BaseActionTile = null # pick step (e.g. Heal): previewed under the mouse on tiles it can go on
var picked: Array[Vector2i] = [] # tiles picked in the pick step, drawn in pick_tile's colour, greyed
var candidates: Array[Vector2i] = [] # empty cells drawn as outlines and clickable (level-up tile placement)
var new_cells: Array[Vector2i] = [] # health cells drawn in COLOR_NEW (tiles just placed)
var shake := Vector2.ZERO: # offset everything is drawn at while the grid shakes (set by the combat scene)
	set(value):
		shake = value
		queue_redraw()

var _hover := NO_CELL
var _origin := Vector2.ZERO
var _hex := HEX_SIZE  # current hex radius
var scale_factor := 1.0  # shrinks HEX_SIZE and MAX_GRID_SIZE: a small minion, or a crowded enemy row
var _info_cell := NO_CELL  # tile under the mouse, for the info panels (any grid, clickable or not)
var _info_power := -1  # index in unit.statuses of the power badge under the mouse
var _info_timer := 0.0
var _powers_y := 0.0  # top of the power badge row
var _info_box := InfoPanel.make_box()
var _particles: Dictionary[String, CPUParticles2D] = {}  # "cell|effect script" -> emitter
var _flashes: Array[Dictionary] = []  # {cell, color, power (script or null), start} playing now


func _ready() -> void:
	_info_box.top_level = true  # positioned in screen space, outside the grid
	_info_box.z_index = 10  # above the hand's cards
	add_child(_info_box)


func setup(_unit: CombatUnit, _clickable: bool) -> void:
	unit = _unit
	clickable = _clickable
	# PASS rather than IGNORE so read-only grids still get hover info.
	mouse_filter = Control.MOUSE_FILTER_STOP if clickable else Control.MOUSE_FILTER_PASS
	mouse_exited.connect(func() -> void:
		_hover = NO_CELL
		_info_cell = NO_CELL
		_info_power = -1
		_info_box.hide()
		queue_redraw())
	refresh()


func refresh() -> void:
	# Measure at hex size 1, then pick the size that fits MAX_GRID_SIZE.
	var min_p := Vector2(INF, INF)
	var max_p := Vector2(-INF, -INF)
	for cell in unit.health.keys() + candidates:
		var p := axial_to_pixel(cell, 1.0)
		min_p = min_p.min(p)
		max_p = max_p.max(p)
	if min_p.x == INF:
		min_p = Vector2.ZERO
		max_p = Vector2.ZERO
	var extent := max_p - min_p + Vector2(2.0, 2.0)  # plus one hex of padding each side
	var fit := MAX_GRID_SIZE * scale_factor
	_hex = minf(HEX_SIZE * scale_factor, minf(fit.x / extent.x, fit.y / extent.y))
	min_p *= _hex
	max_p *= _hex
	for key in _particles:  # rebuilt at the new size by _sync_particles
		_particles[key].queue_free()
	_particles.clear()
	var pad := Vector2(_hex, _hex)
	_origin = -min_p + pad + Vector2(0, NAME_HEIGHT)
	custom_minimum_size = max_p - min_p + pad * 2 + Vector2(0, NAME_HEIGHT)
	_powers_y = custom_minimum_size.y
	# Enemies always keep the row, so their first power doesn't move the grid.
	if not unit.is_player or not unit.statuses.is_empty():
		custom_minimum_size.y += POWER_SIZE + POWER_GAP
	queue_redraw()


func _process(delta: float) -> void:
	if not intents.is_empty() or not placed.is_empty() or random_target:
		queue_redraw()  # keep the intent pulse, placed flash and random-target flicker animating
	if not _flashes.is_empty():
		var now := Time.get_ticks_msec() / 1000.0
		_flashes.assign(_flashes.filter(func(f: Dictionary) -> bool: return now - f.start < FLASH_TIME))
		queue_redraw()
	if (_info_cell != NO_CELL or _info_power != -1) and not _info_box.visible:
		_info_timer -= delta
		if _info_timer <= 0.0:
			if _info_power != -1:
				_show_power_info(_info_power)
			else:
				_show_info(_info_cell)
	_sync_particles()


## One emitter per effect on each tile, using the effect's icon; added and removed as effects come and go.
func _sync_particles() -> void:
	var wanted := {}
	if unit:
		for cell in unit.health:
			for effect in unit.health[cell].status_effects:
				var key := "%s|%s" % [cell, effect.get_script().resource_path]
				wanted[key] = true
				if not _particles.has(key):
					_particles[key] = _make_particles(effect)
					add_child(_particles[key])
				_particles[key].position = cell_position(cell)
	for key in _particles.keys():
		if not wanted.has(key):
			_particles[key].queue_free()
			_particles.erase(key)


func _make_particles(effect: BaseTileEffect) -> CPUParticles2D:
	var particles := CPUParticles2D.new()
	particles.amount = PARTICLE_AMOUNT
	particles.lifetime = PARTICLE_LIFETIME
	particles.preprocess = PARTICLE_LIFETIME  # already drifting when it appears
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	particles.emission_sphere_radius = PARTICLE_SPREAD * _hex / HEX_SIZE
	particles.direction = Vector2.UP
	particles.spread = 20.0
	particles.gravity = Vector2.ZERO
	particles.initial_velocity_min = PARTICLE_SPEED.x
	particles.initial_velocity_max = PARTICLE_SPEED.y
	var ramp := Gradient.new()  # fade in, then out
	ramp.set_color(0, Color(1, 1, 1, 0))
	ramp.set_color(1, Color(1, 1, 1, 0))
	ramp.add_point(0.25, Color.WHITE)
	ramp.add_point(0.7, Color.WHITE)
	particles.color_ramp = ramp
	var icon := effect.get_icon()
	if icon:
		particles.texture = icon
		var scale_amount := PARTICLE_SIZE * _hex / HEX_SIZE / icon.get_width()
		particles.scale_amount_min = scale_amount * 0.8
		particles.scale_amount_max = scale_amount
	else:  # no icon: small dots in the effect's colour
		particles.color = effect.get_color()
		particles.scale_amount_min = 3.0
		particles.scale_amount_max = 4.0
	return particles


func _draw() -> void:
	if unit == null:
		return
	draw_set_transform(shake)
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
		# ponytail: one colour per tile, so Plate hides Poison on the same tile. Draw effect icons if both need to show.
		var plated := tile.has_effect(PlateTileEffect)
		if tile.hp >= Enum.HealthTileEnum.UNDAMAGED:
			alive += 1
			if plated:
				color = COLOR_PLATE
			elif tile.status_effects.size() > 0:
				color = tile.status_effects[0].get_color()
		else:
			color = COLOR_DAMAGED
		if new_cells.has(coord):
			color = COLOR_NEW
		# if action_tile_dict.has(cell):
		# 	color = color.lerp(COLOR_PREVIEW, 0.65)
		var corners := hex_corners(cell_position(coord), _hex - _gap())
		draw_colored_polygon(corners, color)
		corners.append(corners[0])
		draw_polyline(corners, COLOR_EDGE, EDGE_WIDTH * _hex / HEX_SIZE)
		if tile.hp >= Enum.HealthTileEnum.SHIELDED:
			_draw_shield(cell_position(coord), SHIELD_ALPHA)

	for cell in candidates:
		var corners := hex_corners(cell_position(cell), _hex - _gap())
		if cell == _hover:
			draw_colored_polygon(corners, Color(COLOR_CANDIDATE, 0.35))
		corners.append(corners[0])
		draw_polyline(corners, Color(COLOR_CANDIDATE, 0.8), maxf(1.0, 2.0 * _hex / HEX_SIZE))

	var wave := 0.5 + 0.5 * sin(TAU * Time.get_ticks_msec() / 1000.0 / INTENT_PERIOD)
	var pulse := lerpf(ICON_ALPHA_MIN, ICON_ALPHA_MAX, wave)
	for intent in intents:
		var alpha := pulse * (INTENT_FADE if intent.get("faded", false) else 1.0)
		for t: BaseActionTile in intent.tiles:
			var cell: Vector2i = intent.cell + t.coords
			if unit.health.has(cell):
				_draw_action(t, cell, alpha)

	var flash := 0.5 + 0.5 * sin(TAU * Time.get_ticks_msec() / 1000.0 / PLACED_PERIOD)
	for p in placed:
		for offset: Vector2i in p.tiles:
			var cell: Vector2i = p.cell + offset
			if unit.health.has(cell):
				var t: BaseActionTile = p.tiles[offset]
				draw_colored_polygon(hex_corners(cell_position(cell), _hex - 2.5), Color(t.get_color(), flash * PLACED_FILL))
				_draw_action(t, cell, lerpf(ICON_ALPHA_MIN, ICON_ALPHA_MAX, flash))

	var flicker_wave := 0.5 + 0.5 * sin(TAU * Time.get_ticks_msec() / 1000.0 / FLICKER_PERIOD)
	var flicker := lerpf(ICON_ALPHA_MIN, ICON_ALPHA_MAX, flicker_wave)

	if random_target:
		# Steady while hovered, flickering otherwise, on every tile it could hit.
		var alpha := PREVIEW_ALPHA if unit.health.has(_hover) else flicker
		for cell in unit.health:
			if random_target.can_inflict(unit, cell):
				draw_colored_polygon(hex_corners(cell_position(cell), _hex - _gap()), Color(random_target.get_color(), alpha * 0.5))

	for offset in preview:
		var cell := _hover + offset
		if unit.health.has(cell):
			_draw_action(preview[offset], cell, PREVIEW_ALPHA)

	if pick_tile:
		for cell in picked:
			draw_colored_polygon(hex_corners(cell_position(cell), _hex - 2.5), pick_tile.get_color().lerp(COLOR_DAMAGED, PICKED_GREY))
		if _hover not in picked and pick_tile.can_pick(unit, _hover, picked):
			_draw_action(pick_tile, _hover, PREVIEW_ALPHA)

	var font := ThemeDB.fallback_font
	var title := "%s  %d/%d" % [unit.display_name, alive, coords.size()]
	draw_string(font, Vector2(0, 27), title, HORIZONTAL_ALIGNMENT_CENTER, size.x, 27, COLOR_TEXT)

	# Power badges: icon with its stack count in the corner.
	for i in unit.statuses.size():
		var power := unit.statuses[i] as BasePower
		if power == null:
			continue
		var rect := _power_rect(i)
		draw_texture_rect(power.get_icon(), rect, false)
		if not power.show_amount:
			continue
		var corner := rect.end - Vector2(rect.size.x, 2)
		draw_string_outline(font, corner, str(power.amount), HORIZONTAL_ALIGNMENT_RIGHT, rect.size.x, 20, 4, Color.BLACK)
		draw_string(font, corner, str(power.amount), HORIZONTAL_ALIGNMENT_RIGHT, rect.size.x, 20, power.get_color())

	# Changes being animated, on top of everything: fade out while popping up and back.
	var now := Time.get_ticks_msec() / 1000.0
	for f in _flashes:
		var t := clampf((now - f.start) / FLASH_TIME, 0.0, 1.0)
		var pop := 1.0 + FLASH_POP * sin(PI * t)
		var color := Color(f.color, 1.0 - t)
		if f.power:
			var i := unit.statuses.find_custom(func(e: BaseEffect) -> bool: return e.get_script() == f.power)
			if i != -1:
				draw_rect(_power_rect(i).grow(POWER_SIZE * (pop - 1.0) / 2.0), color, false, 3.0)
		else:
			draw_colored_polygon(hex_corners(cell_position(f.cell), (_hex - 2.5) * pop), color)


## Plays one change on this grid for FLASH_TIME: the cell, or the power's badge, flashes and pops.
## One branch per kind, so a kind can get its own VFX later.
func flash(cell: Vector2i, kind: Enum.Change, effect: BaseEffect) -> void:
	var color := COLOR_ALIVE
	match kind:
		Enum.Change.DAMAGE:
			color = COLOR_PREVIEW
		Enum.Change.BLOCK, Enum.Change.SHIELD:
			color = COLOR_SHIELDED
		Enum.Change.EFFECT, Enum.Change.EFFECT_LOST, Enum.Change.POWER:
			color = effect.get_color()
		Enum.Change.HEAL:
			color = COLOR_HEAL
	var power: Script = effect.get_script() if kind == Enum.Change.POWER else null
	_flashes.append({cell = cell, color = color, power = power, start = Time.get_ticks_msec() / 1000.0})
	queue_redraw()


## Badge i in the row under the grid, centred.
func _power_rect(i: int) -> Rect2:
	var count := unit.statuses.size()
	var width := count * POWER_SIZE + (count - 1) * POWER_GAP
	var x := (size.x - width) / 2 + i * (POWER_SIZE + POWER_GAP)
	return Rect2(x, _powers_y, POWER_SIZE, POWER_SIZE)


func _power_at(p: Vector2) -> int:
	for i in unit.statuses.size():
		if _power_rect(i).has_point(p):
			return i
	return -1


## Info panels for a tile, like a card's keyword panels: its state (if not plain healthy),
## then one panel per effect. Shown beside the tile, flipped left near the screen edge.
func _show_info(cell: Vector2i) -> void:
	InfoPanel.clear(_info_box)
	var tile: HealthTile = unit.health[cell]
	match tile.hp:
		Enum.HealthTileEnum.DAMAGED:
			_info_box.add_child(InfoPanel.make("Damaged", "This tile is lost and no longer counts toward health."))
		Enum.HealthTileEnum.SHIELDED:
			_info_box.add_child(InfoPanel.make("Shielded", "Blocks the next hit on this tile.", COLOR_SHIELDED))
	for effect in tile.status_effects:
		var turns := "" if effect.turns < 0 else " (%d turn%s)" % [effect.turns, "" if effect.turns == 1 else "s"]
		_info_box.add_child(InfoPanel.make(effect.name + turns, effect.description, effect.get_color()))
	if _info_box.get_child_count() == 0:
		return
	_info_box.reset_size()
	var tile_center := get_global_transform() * (_origin + cell_position(cell))
	var pos := tile_center + Vector2(_hex + InfoPanel.GAP, -_hex)
	var screen := get_viewport_rect().size
	if pos.x + _info_box.size.x > screen.x:
		pos.x = tile_center.x - _hex - InfoPanel.GAP - _info_box.size.x
	pos.y = clampf(pos.y, 0.0, maxf(0.0, screen.y - _info_box.size.y))
	_info_box.position = pos
	_info_box.show()


## Name with stacks, and description, beside the badge.
func _show_power_info(i: int) -> void:
	InfoPanel.clear(_info_box)
	var power := unit.statuses[i] as BasePower
	if power == null:
		return
	var title := "%s %d" % [power.name, power.amount] if power.show_amount else power.name
	_info_box.add_child(InfoPanel.make(title, power.get_description(), power.get_color()))
	_info_box.reset_size()
	var rect := get_global_transform() * _power_rect(i)
	var pos := Vector2(rect.end.x + InfoPanel.GAP, rect.position.y)
	var screen := get_viewport_rect().size
	if pos.x + _info_box.size.x > screen.x:
		pos.x = rect.position.x - InfoPanel.GAP - _info_box.size.x
	pos.y = clampf(pos.y, 0.0, maxf(0.0, screen.y - _info_box.size.y))
	_info_box.position = pos
	_info_box.show()


## What an action will do to a tile: its icon, a small shield hex, or (no icon) its colour.
func _draw_action(t: BaseActionTile, cell: Vector2i, alpha: float) -> void:
	var center := cell_position(cell)
	if t is ShieldTile:
		_draw_shield(center, alpha * SHIELD_ALPHA)
		return
	var icon := t.get_icon()
	if icon:
		var half := Vector2.ONE * ICON_SIZE * _hex / HEX_SIZE / 2.0
		draw_texture_rect(icon, Rect2(center - half, half * 2.0), false, Color(1, 1, 1, alpha))
	else:
		draw_colored_polygon(hex_corners(center, _hex - _gap()), Color(t.get_color(), alpha * 0.5))


func _draw_shield(center: Vector2, alpha: float) -> void:
	draw_colored_polygon(hex_corners(center, _hex * SHIELD_SCALE), Color(COLOR_SHIELDED, alpha))


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var hovered := _pixel_to_axial(event.position - _origin)
		if not unit.health.has(hovered):
			hovered = NO_CELL
		var power := _power_at(event.position)
		if hovered != _info_cell or power != _info_power:
			_info_cell = hovered
			_info_power = power
			_info_timer = InfoPanel.DELAY
			_info_box.hide()
	if not clickable:
		return
	if event is InputEventMouseMotion:
		var cell := _pixel_to_axial(event.position - _origin)
		if cell != _hover:
			_hover = cell
			queue_redraw()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var cell := _pixel_to_axial(event.position - _origin)
		if unit.health.has(cell) or candidates.has(cell):
			accept_event()
			cell_clicked.emit(unit, cell)


func _gap() -> float:
	return GAP * _hex / HEX_SIZE


## Centre of a cell in this grid's local coordinates.
func cell_position(cell: Vector2i) -> Vector2:
	return _origin + axial_to_pixel(cell, _hex)


static func axial_to_pixel(c: Vector2i, hex_size := HEX_SIZE) -> Vector2:
	return Vector2(hex_size * SQRT3 * (c.x + c.y / 2.0), hex_size * 1.5 * c.y)


func _pixel_to_axial(p: Vector2) -> Vector2i:
	return pixel_to_axial(p, _hex)


## Inverse of axial_to_pixel: the cell whose hex contains p.
static func pixel_to_axial(p: Vector2, hex_size: float) -> Vector2i:
	var fq := (SQRT3 / 3.0 * p.x - p.y / 3.0) / hex_size
	var fr := (2.0 / 3.0 * p.y) / hex_size
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
