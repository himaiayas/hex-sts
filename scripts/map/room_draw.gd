class_name RoomDraw


const SQRT3 := 1.7320508
const INSET := 0.94 #gap
const COLOR_ROOM := Color("#262a35")
const COLOR_ROOM_EDGE := Color("#3b4152")
const COLOR_DOOR := Color("#9aa1b5")
const COLOR_ENTRY := Color("#ffd45a")
const COLOR_ICON := Color.WHITE
const ICON_SCALE := 2.6  # image width in units of the icon size s

## Room images; types not listed (START, BOSS_COMBAT) are drawn with shapes.
const ROOM_ICONS := {
	Enum.RoomType.NORMAL_COMBAT: preload("res://assets/icons/room_normal_combat.png"),
	Enum.RoomType.ELITE_COMBAT: preload("res://assets/icons/room_elite_combat.png"),
	Enum.RoomType.CAMPFIRE: preload("res://assets/icons/room_campfire.png"),
	Enum.RoomType.CARD_SHOP: preload("res://assets/icons/room_merchant.png"),
	Enum.RoomType.AUGMENT_SHOP: preload("res://assets/icons/room_blacksmith.png"),
	Enum.RoomType.TREASURE: preload("res://assets/icons/room_treasure.png"),
	Enum.RoomType.EVENT: preload("res://assets/icons/room_event.png"),
}


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
	if ROOM_ICONS.has(type):
		var half := Vector2.ONE * s * ICON_SCALE * 0.5
		ci.draw_texture_rect(ROOM_ICONS[type], Rect2(c - half, half * 2.0), false)
		return
	var width := maxf(2.0, s * 0.12)
	match type:
		Enum.RoomType.START:
			ci.draw_arc(c, s * 0.8, 0.0, TAU, 32, COLOR_ICON, width)
			ci.draw_circle(c, s * 0.25, COLOR_ICON)
		Enum.RoomType.BOSS_COMBAT:
			# Skull.
			ci.draw_circle(c + Vector2(0, -0.15 * s), 0.7 * s, COLOR_ICON)
			ci.draw_rect(Rect2(c + Vector2(-0.4 * s, 0.3 * s), Vector2(0.8 * s, 0.5 * s)), COLOR_ICON)
			for x in [-0.28, 0.28]:
				ci.draw_circle(c + Vector2(x * s, -0.15 * s), 0.17 * s, COLOR_ROOM)
