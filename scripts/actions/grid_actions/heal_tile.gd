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

func get_icon() -> Texture2D:
	return preload("res://assets/grid_effects/heal.png")

func describe() -> String:
	return "Heals this tile if it's damaged."

func display_name() -> String:
	return "Heal"
