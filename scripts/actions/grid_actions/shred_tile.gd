class_name ShredTile
extends BaseActionTile

## Removes Plate from the tile (Cleaner Bot's Shred). Its Shield, if any, stays for now.


func _init(_coord: Vector2i)->void:
	super(_coord)

func inflict(combat: CombatState, unit: CombatUnit, cell: Vector2i)->bool:
	if not can_inflict(unit, cell):
		return false
	return PlateTileEffect.strip(combat, unit, cell)

## Only Plated tiles.
func can_inflict(unit: CombatUnit, cell: Vector2i)->bool:
	return unit.health.has(cell) and unit.health[cell].has_effect(PlateTileEffect)

func get_color()->Color:
	return HealthGridView.COLOR_PLATE.darkened(0.4)

func get_icon() -> Texture2D:
	return preload("res://assets/grid_effects/plate.png")

func describe() -> String:
	return "Removes Plate from this tile."

func display_name() -> String:
	return "Shred"
