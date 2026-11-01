class_name ApplyEffectTile
extends BaseActionTile


var effect: BaseEffect
func _init(_coords: Vector2i, _effect: BaseTileEffect)->void:
	super(_coords)
	effect = _effect

func inflict(_combat: CombatState, unit: CombatUnit, cell: Vector2i)->bool:
	if not can_inflict(unit, cell):
		return false
	unit.apply_effect_health_tile(cell, effect.copy() as BaseTileEffect)
	return true

func get_color()->Color:
	return effect.get_color()

func get_icon() -> Texture2D:
	return effect.get_icon()
