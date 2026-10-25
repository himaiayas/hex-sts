class_name PatternView
extends Control

## Draws a card's tile pattern as small hexes, shrunk to fit the box.
## The (0,0) hex, where the cursor goes when you play the card, is outlined.

const BOX_SIZE := Vector2(124, 28)
const MAX_HEX_SIZE := 10.0
const COLOR_EDGE := Color("#151515")
const COLOR_ORIGIN := Color("#ffffff")

var tiles: Array[BaseActionTile] = []


func _init(_tiles: Array[BaseActionTile]) -> void:
	tiles = _tiles
	custom_minimum_size = BOX_SIZE
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _draw() -> void:
	# Measure the pattern with hex size 1, then scale it to fit.
	var min_p := Vector2.ZERO
	var max_p := Vector2.ZERO
	for t in tiles:
		var p := HealthGridView.axial_to_pixel(t.coords, 1.0)
		min_p = min_p.min(p)
		max_p = max_p.max(p)
	var extent := max_p - min_p + Vector2(HealthGridView.SQRT3, 2.0)  # a size-1 hex is sqrt3 wide, 2 tall
	var hex_size := minf(MAX_HEX_SIZE, minf(size.x / extent.x, size.y / extent.y))
	var offset := size / 2 - (min_p + max_p) / 2 * hex_size

	for t in tiles:
		var points := HealthGridView.hex_corners(offset + HealthGridView.axial_to_pixel(t.coords, hex_size), hex_size - 1.0)
		draw_colored_polygon(points, t.get_color())
		points.append(points[0])
		draw_polyline(points, COLOR_EDGE, 1.0)

	var origin := HealthGridView.hex_corners(offset, hex_size - 1.0)
	origin.append(origin[0])
	draw_polyline(origin, COLOR_ORIGIN, 2.0)
