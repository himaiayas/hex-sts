class_name ApplyEffectTile
extends BaseActionTile


var effect: BaseEffect
func _init(_coords: Vector2i, _effect: BaseTileEffect)->void:
	super(_coords)
	effect = _effect

func inflict(cell: Vector2i, ctx: ActionContext)->void:
	if ctx.target.health.has(cell):
		ctx.target.apply_effect_health_tile(cell, effect)

func get_color()->Color:
	return effect.get_color()
