class_name ShieldTile
extends BaseActionTile


func _init(_coord: Vector2i)->void:
	super(_coord)

func inflict(_combat: CombatState, unit: CombatUnit, cell: Vector2i)->void:
	if unit.health.has(cell) and unit.health[cell].hp != HealthTile.HealthTileEnum.DAMAGED:
		unit.shield_health_tile(cell)

func get_color()->Color:
	return Color("#a0e5f6")