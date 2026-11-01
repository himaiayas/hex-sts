class_name ShieldTile
extends BaseActionTile


func _init(_coord: Vector2i)->void:
	super(_coord)

func inflict(_combat: CombatState, unit: CombatUnit, cell: Vector2i)->bool:
	if not can_inflict(unit, cell):
		return false
	unit.shield_health_tile(cell)
	return true

## Already shielded tiles are skipped too, so a random shield is never wasted.
func can_inflict(unit: CombatUnit, cell: Vector2i)->bool:
	return unit.health.has(cell) and unit.health[cell].hp == Enum.HealthTileEnum.UNDAMAGED

func get_color()->Color:
	return Color("#a0e5f6")

func display_name() -> String:
	return "Shield"
