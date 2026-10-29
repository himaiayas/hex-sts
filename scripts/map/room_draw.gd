class_name RoomDraw


const SQRT3 := 1.7320508
const INSET := 0.94 #gap
const COLOR_ROOM := Color("#262a35")
const COLOR_ROOM_EDGE := Color("#3b4152")
const COLOR_DOOR := Color("#9aa1b5")
const COLOR_ENTRY := Color("#ffd45a")
const COLOR_ICON := Color.WHITE


static func axial_to_pixel(c: Vector2i, size: float) -> Vector2:
	return Vector2(size * 1.5 * c.x, size * SQRT3 * (c.y + c.x * 0.5))


static func pixel_to_axial(p: Vector2, size: float) -> Vector2i:
	var fq := (2.0 / 3.0 * p.x) / size
	var fr := (-1.0 / 3.0 * p.x + SQRT3 / 3.0 * p.y) / size
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


static func corners(center: Vector2, radius: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	for k in 6:
		var angle := deg_to_rad(60.0 * k)
		points.append(center + Vector2(cos(angle), sin(angle)) * radius)
	return points


static func draw_room(ci: CanvasItem, center: Vector2, size: float, room: MapRoom, 
		fill := COLOR_ROOM, entry_door := -1) -> void: #need fix
	var points := corners(center, size * INSET)
	ci.draw_colored_polygon(points, fill)
	points.append(points[0])
	ci.draw_polyline(points, COLOR_ROOM_EDGE, 2.0)

	for dir in room.doors:
		var mid := center + axial_to_pixel(MapState.DIRS[dir], size) * 0.5 * INSET
		var along := (mid - center).normalized().orthogonal() * size * 0.22
		var color := COLOR_ENTRY if dir == entry_door else COLOR_DOOR
		ci.draw_line(mid - along, mid + along, color, size * 0.12)

	draw_icon(ci, center, size * 0.32, room.type)


static func draw_icon(ci: CanvasItem, c: Vector2, s: float, type: int) -> void:
	var width := maxf(2.0, s * 0.12)
	match type:
		Enum.RoomType.START:
			ci.draw_arc(c, s * 0.8, 0.0, TAU, 32, COLOR_ICON, width)
			ci.draw_circle(c, s * 0.25, COLOR_ICON)
		Enum.RoomType.NORMAL_COMBAT:
			# Draw swords. We will use image assets instead.
			_draw_swords(ci, c, s, width)
		Enum.RoomType.ELITE_COMBAT:
			_draw_swords(ci, c, s * 0.85, width)
			ci.draw_arc(c, s * 1.05, 0.0, TAU, 32, COLOR_ICON, width)
		Enum.RoomType.BOSS_COMBAT:
			# Skull.
			ci.draw_circle(c + Vector2(0, -0.15 * s), 0.7 * s, COLOR_ICON)
			ci.draw_rect(Rect2(c + Vector2(-0.4 * s, 0.3 * s), Vector2(0.8 * s, 0.5 * s)), COLOR_ICON)
			for x in [-0.28, 0.28]:
				ci.draw_circle(c + Vector2(x * s, -0.15 * s), 0.17 * s, COLOR_ROOM)
		Enum.RoomType.CAMPFIRE:
			var flame := PackedVector2Array([
				c + Vector2(0, -0.9 * s), c + Vector2(0.45 * s, 0.1 * s),
				c + Vector2(0.3 * s, 0.45 * s), c + Vector2(-0.3 * s, 0.45 * s),
				c + Vector2(-0.45 * s, 0.1 * s),
			])
			ci.draw_colored_polygon(flame, COLOR_ICON)
			ci.draw_line(c + Vector2(-0.7 * s, 0.85 * s), c + Vector2(0.7 * s, 0.55 * s), COLOR_ICON, width)
			ci.draw_line(c + Vector2(-0.7 * s, 0.55 * s), c + Vector2(0.7 * s, 0.85 * s), COLOR_ICON, width)
		Enum.RoomType.CARD_SHOP:
			# Two fanned cards.
			for angle in [-0.25, 0.25]:
				var card := PackedVector2Array()
				for corner in [Vector2(-0.4, -0.6), Vector2(0.4, -0.6), Vector2(0.4, 0.6), Vector2(-0.4, 0.6), Vector2(-0.4, -0.6)]:
					card.append(c + (corner * s).rotated(angle) + Vector2(angle * s, 0))
				ci.draw_polyline(card, COLOR_ICON, width)
		Enum.RoomType.AUGMENT_SHOP:
			# Gem.
			var gem := PackedVector2Array([
				c + Vector2(-0.8 * s, -0.25 * s), c + Vector2(-0.45 * s, -0.7 * s),
				c + Vector2(0.45 * s, -0.7 * s), c + Vector2(0.8 * s, -0.25 * s),
				c + Vector2(0, 0.85 * s), c + Vector2(-0.8 * s, -0.25 * s),
			])
			ci.draw_polyline(gem, COLOR_ICON, width)
			ci.draw_line(c + Vector2(-0.8 * s, -0.25 * s), c + Vector2(0.8 * s, -0.25 * s), COLOR_ICON, width)
		Enum.RoomType.TREASURE:
			# Chest.
			ci.draw_rect(Rect2(c + Vector2(-0.8 * s, -0.5 * s), Vector2(1.6 * s, 1.2 * s)), COLOR_ICON, false, width)
			ci.draw_line(c + Vector2(-0.8 * s, -0.05 * s), c + Vector2(0.8 * s, -0.05 * s), COLOR_ICON, width)
			ci.draw_rect(Rect2(c + Vector2(-0.15 * s, -0.2 * s), Vector2(0.3 * s, 0.35 * s)), COLOR_ICON)
		Enum.RoomType.EVENT:
			var font := ThemeDB.fallback_font
			var font_size := int(s * 2.0)
			ci.draw_string(font, c + Vector2(-s, font.get_ascent(font_size) * 0.38), "?",
				HORIZONTAL_ALIGNMENT_CENTER, 2.0 * s, font_size, COLOR_ICON)


static func _draw_swords(ci: CanvasItem, c: Vector2, s: float, width: float) -> void:
	for flip in [1.0, -1.0]:
		var tip := c + Vector2(0.8 * s * flip, -0.8 * s)
		var hilt := c + Vector2(-0.8 * s * flip, 0.8 * s)
		ci.draw_line(hilt, tip, COLOR_ICON, width)
		var guard := c + Vector2(-0.45 * s * flip, 0.45 * s)
		var across := Vector2(1.0, flip).normalized() * s * 0.25
		ci.draw_line(guard - across, guard + across, COLOR_ICON, width)
