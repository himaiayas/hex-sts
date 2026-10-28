class_name ApplyPowerAction
extends BaseAction

var power: BaseEffect

func _init(_target: Enum.TargetType, _power: BaseEffect) -> void:
	super(_target)
	power = _power

func execute(_combat: CombatState, unit: CombatUnit, _cell: Vector2i)->void:
	unit.add_power(power.copy())
