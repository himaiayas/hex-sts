class_name CleanseTile
extends BaseActionTile

## Removes every debuff tile effect (BaseTileEffect.debuff) from the tile. Buffs like Plate stay.


func _init(_coord: Vector2i)->void:
	super(_coord)

func inflict(combat: CombatState, unit: CombatUnit, cell: Vector2i)->bool:
	if not can_inflict(unit, cell):
		return false
	var effects: Array = unit.health[cell].status_effects
	for effect in effects.duplicate():
		if _is_debuff(effect):
			effects.erase(effect)
			combat.record(unit, cell, Enum.Change.EFFECT_LOST, effect)
	return true

## Only tiles with a debuff on them, damaged or not (Poison stays on a damaged tile).
func can_inflict(unit: CombatUnit, cell: Vector2i)->bool:
	return unit.health.has(cell) and unit.health[cell].status_effects.any(_is_debuff)

func get_color()->Color:
	return Color("#e8e3a0")

func display_name() -> String:
	return "Cleanse"


func _is_debuff(effect: BaseEffect) -> bool:
	return effect is BaseTileEffect and effect.debuff
