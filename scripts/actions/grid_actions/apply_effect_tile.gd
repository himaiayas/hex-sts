class_name ApplyEffectTile
extends BaseActionTile


var effect: BaseEffect
func _init(_coords: Vector2i, _effect: BaseTileEffect)->void:
	super(_coords)
	effect = _effect

func inflict(combat: CombatState, unit: CombatUnit, cell: Vector2i)->bool:
	if not can_inflict(unit, cell):
		return false
	unit.apply_effect_health_tile(combat, cell, effect.copy() as BaseTileEffect)
	return true

## Most effects only go on undamaged tiles; allow_damaged ones (Poison) go on any tile.
func can_inflict(unit: CombatUnit, cell: Vector2i)->bool:
	return unit.health.has(cell) and (unit.health[cell].hp != Enum.HealthTileEnum.DAMAGED or (effect as BaseTileEffect).allow_damaged)

func get_color()->Color:
	return effect.get_color()

func get_icon() -> Texture2D:
	return effect.get_icon()

func describe() -> String:
	return effect.description

func display_name() -> String:
	return effect.name

func copy_at(at: Vector2i) -> BaseActionTile:
	return ApplyEffectTile.new(at, effect.copy() as BaseTileEffect)

## One kind per effect: Poison and Plate tiles differ.
func kind() -> String:
	return super() + "|" + effect.get_script().resource_path
