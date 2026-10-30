class_name DamageTile
extends BaseActionTile


func _init(_coord: Vector2i)->void:
	super(_coord)

func inflict(combat: CombatState, unit: CombatUnit, cell: Vector2i)->void:
	if unit.health.has(cell):
		unit.damage_health_tile(combat, cell)

func get_color()->Color:
	return Color("#ff7a7a")

func get_icon() -> Texture2D:
	return preload("res://assets/grid_effects/damage.png")
