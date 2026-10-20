class_name DrawAction
extends BaseAction

var amount: int

func _init(_target: TargetType = TargetType.PLAYER, _amount := 1)->void:
	super(_target)
	amount = _amount

func execute(ctx: ActionContext)->void:
	ctx.combat.draw(amount)
