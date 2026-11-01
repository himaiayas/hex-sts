class_name DrawAction
extends BaseAction

var amount: int

func _init(_target: Enum.TargetType = Enum.TargetType.PLAYER, _amount := 1)->void:
	super(_target)
	amount = _amount

func execute(combat: CombatState, _unit: CombatUnit, _cell: Vector2i)->Array[Vector2i]:
	combat.draw(amount)
	return []
