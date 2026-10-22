class_name DamageTile
extends BaseActionTile


func _init(_coord: Vector2i)->void:
	super(_coord)

func inflict(_combat: CombatState, unit: CombatUnit, cell: Vector2i)->void:
	if unit.health.has(cell):
		unit.damage_health_tile(cell)

func get_color()->Color:
	return Color("#ff7a7a")
