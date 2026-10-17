class_name DamageTile
extends BaseActionTile

var amount: int

func _init(_coords: Vector2i, _amount := 0)->void:
	super(_coords)
	amount = _amount

func inflict(cell: Vector2i, ctx: ActionContext)->void:
	var unit := ctx.combat.unit_at(cell)
	if unit:
		unit.take_damage(amount)
