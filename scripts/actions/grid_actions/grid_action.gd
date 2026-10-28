class_name GridAction
extends BaseAction

var tiles:Array[BaseActionTile]
var anchor: Vector2i

func _init(_target: TargetType, _tiles:Array[BaseActionTile], _anchor: Vector2i=Vector2i.ZERO)->void:
	target = _target
	tiles = _tiles
	anchor = _anchor

## rotation = 60° clockwise steps around the clicked cell.
func execute(combat: CombatState, unit: CombatUnit, cell: Vector2i, rotation := 0)->void:
	var pattern := rotated(rotation)
	for offset in pattern:
		pattern[offset].inflict(combat, unit, cell + offset)

## New dict of offset from the clicked cell -> tile, turned 60° clockwise per step. Never changes tiles itself.
func rotated(steps: int)->Dictionary[Vector2i, BaseActionTile]:
	var pattern: Dictionary[Vector2i, BaseActionTile] = {}
	for t in tiles:
		var offset := t.coords + anchor
		for i in posmod(steps, 6):
			offset = rotate_cw(offset)
		pattern[offset] = t
	return pattern

## Axial (q, r) -> (-r, q+r). Anticlockwise (q+r, -q) is 5 clockwise steps.
static func rotate_cw(c: Vector2i)->Vector2i:
	return Vector2i(-c.y, c.x + c.y)
