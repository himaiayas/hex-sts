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
		Enum.RoomType.COMBAT:
			# Draw swords. We will use image assets instead.
			for flip in [1.0, -1.0]:
				var tip := c + Vector2(0.8 * s * flip, -0.8 * s)
				var hilt := c + Vector2(-0.8 * s * flip, 0.8 * s)
				ci.draw_line(hilt, tip, COLOR_ICON, width)
				var guard := c + Vector2(-0.45 * s * flip, 0.45 * s)
				var across := Vector2(1.0, flip).normalized() * s * 0.25
				ci.draw_line(guard - across, guard + across, COLOR_ICON, width)
