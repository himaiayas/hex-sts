class_name GridAction
extends BaseAction

var tiles:Array[BaseActionTile]
var anchor: Vector2i
## Every tile must land on an undamaged (or shielded) tile of the grid. For patterns that hurt
## whoever they're placed on (e.g. Damage or Fracture on your own grid), so they can't be dodged
## by placing them on damaged tiles or off the grid.
var must_land := false

func _init(_target: Enum.TargetType, _tiles:Array[BaseActionTile], _anchor: Vector2i=Vector2i.ZERO, _must_land := false)->void:
	target = _target
	tiles = _tiles
	anchor = _anchor
	must_land = _must_land


## Whether the pattern may go at cell on unit's grid with this rotation (always, unless must_land).
func can_place(unit: CombatUnit, cell: Vector2i, rotation := 0)->bool:
	if not must_land:
		return true
	for offset in rotated(rotation):
		if not unit.health.has(cell + offset) or unit.health[cell + offset].hp == Enum.HealthTileEnum.DAMAGED:
			return false
	return true


## Whether there's any cell and rotation on unit's grid where it may go.
func can_place_anywhere(unit: CombatUnit)->bool:
	if not must_land:
		return true
	for cell in unit.health:
		for rotation in 6:
			if can_place(unit, cell, rotation):
				return true
	return false

## rotation = 60° clockwise steps around the clicked cell. Returns the cells it changed.
func execute(combat: CombatState, unit: CombatUnit, cell: Vector2i, rotation := 0)->Array[Vector2i]:
	var pattern := rotated(rotation)
	var hits: Array[Vector2i] = []
	var landed := []  # [unit, cell] of damage tiles on the grid, hit or not, for Strength
	for offset in pattern:
		if pattern[offset] is DamageTile and unit.health.has(cell + offset):
			landed.append([unit, cell + offset])
		if pattern[offset].inflict(combat, unit, cell + offset):
			hits.append(cell + offset)
	await combat.flush()
	hits.append_array(StrengthPower.spread(combat, landed))
	await combat.flush()  # Strength's extras play after the pattern
	return hits

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
