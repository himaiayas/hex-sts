class_name SacrificeTile
extends BaseActionTile

## Destroys one of your own tiles as a cost. A Shield doesn't absorb it.


func _init(_coord: Vector2i)->void:
	super(_coord)

func inflict(combat: CombatState, unit: CombatUnit, cell: Vector2i)->bool:
	return can_inflict(unit, cell) and unit.damage_health_tile(combat, cell, true)

## A Plated tile can only be picked once every other undamaged tile is picked.
func can_pick(unit: CombatUnit, cell: Vector2i, picked: Array[Vector2i])->bool:
	if not can_inflict(unit, cell):
		return false
	if not unit.health[cell].has_effect(PlateTileEffect):
		return true
	for other in unit.health:
		if other != cell and other not in picked and can_inflict(unit, other) \
				and not unit.health[other].has_effect(PlateTileEffect):
			return false
	return true

func get_color()->Color:
	return Color("#b03a48")

func display_name() -> String:
	return "Sacrifice"
