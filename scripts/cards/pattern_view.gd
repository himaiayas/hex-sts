class_name PatternView
extends Control

## Draws one of a card's grid actions as small hexes, shrunk to fit the box.
## The (0,0) hex, where the cursor goes when you play the card, is outlined.

const BOX_SIZE := Vector2(207, 47)
const MAX_HEX_SIZE := 17.0
const COLOR_EDGE := Color("#151515")
const COLOR_ORIGIN := Color("#ffffff")

var action: GridAction


## height > 0: an inline pattern that height tall and just as wide as it needs.
func _init(_action: GridAction, height := 0.0) -> void:
	action = _action
	custom_minimum_size = BOX_SIZE
	if height > 0:
		var extent: Vector2 = _extent()[2]
		var hex := minf(MAX_HEX_SIZE, height / extent.y)
		custom_minimum_size = Vector2(ceilf(extent.x * hex), height)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


## [min, max, extent] of the pattern at hex size 1.
func _extent() -> Array:
	var min_p := Vector2.ZERO
	var max_p := Vector2.ZERO
	for t in action.tiles:
		var p := HealthGridView.axial_to_pixel(t.coords + action.anchor, 1.0)
		min_p = min_p.min(p)
		max_p = max_p.max(p)
	return [min_p, max_p, max_p - min_p + Vector2(HealthGridView.SQRT3, 2.0)]  # a size-1 hex is sqrt3 wide, 2 tall


func _draw() -> void:
	# Measure the pattern with hex size 1, then scale it to fit.
	var bounds := _extent()
	var min_p: Vector2 = bounds[0]
	var max_p: Vector2 = bounds[1]
	var extent: Vector2 = bounds[2]
	var hex_size := minf(MAX_HEX_SIZE, minf(size.x / extent.x, size.y / extent.y))
	var offset := size / 2 - (min_p + max_p) / 2 * hex_size

	for t in action.tiles:
		var points := HealthGridView.hex_corners(offset + HealthGridView.axial_to_pixel(t.coords + action.anchor, hex_size), hex_size - 1.5)
		draw_colored_polygon(points, t.get_color())
		points.append(points[0])
		draw_polyline(points, COLOR_EDGE, 2.0)

	var origin := HealthGridView.hex_corners(offset, hex_size - 1.5)
	origin.append(origin[0])
	draw_polyline(origin, COLOR_ORIGIN, 3.0)
