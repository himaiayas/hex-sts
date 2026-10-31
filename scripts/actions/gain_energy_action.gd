class_name GainEnergyAction
extends BaseAction

var amount: int

func _init(_target: Enum.TargetType = Enum.TargetType.PLAYER, _amount := 1)->void:
	super(_target)
	amount = _amount

## Not capped by max_energy; the extra is spent or lost by the end of the turn.
func execute(combat: CombatState, _unit: CombatUnit, _cell: Vector2i)->Array[Vector2i]:
	combat.energy += amount
	return []
