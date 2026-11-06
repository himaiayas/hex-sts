class_name HealTile
extends BaseActionTile


func _init(_coord: Vector2i)->void:
	super(_coord)

func inflict(combat: CombatState, unit: CombatUnit, cell: Vector2i)->bool:
	return unit.health.has(cell) and unit.heal_health_tile(combat, cell)

## Only damaged tiles can be healed.
func can_inflict(unit: CombatUnit, cell: Vector2i)->bool:
	return unit.health.has(cell) and unit.health[cell].hp == Enum.HealthTileEnum.DAMAGED

func get_color()->Color:
	return HealthGridView.COLOR_HEAL

func display_name() -> String:
	return "Heal"
