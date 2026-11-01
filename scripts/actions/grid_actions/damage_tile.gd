class_name DamageTile
extends BaseActionTile


func _init(_coord: Vector2i)->void:
	super(_coord)

## True only when the tile ends up damaged, not when a shield blocks it.
func inflict(combat: CombatState, unit: CombatUnit, cell: Vector2i)->bool:
	return unit.health.has(cell) and unit.damage_health_tile(combat, cell)

func get_color()->Color:
	return Color("#ff7a7a")

func get_icon() -> Texture2D:
	return preload("res://assets/grid_effects/damage.png")

func display_name() -> String:
	return "Damage"
