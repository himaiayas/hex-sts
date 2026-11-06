class_name ApplyPowerAction
extends BaseAction

var power: BaseEffect

func _init(_target: Enum.TargetType, _power: BaseEffect) -> void:
	super(_target)
	power = _power

func execute(combat: CombatState, unit: CombatUnit, _cell: Vector2i)->Array[Vector2i]:
	unit.add_power(combat, power.copy())
	await combat.flush()
	return []
