class_name RamielStunned
extends BaseEnemyAction

## An interrupted Charge: Ramiel does nothing this turn.


func _init() -> void:
	super(Enum.BaseEnemyActionEnum.DEBUFF, "Stunned", 1.0)


func execute(_combat: CombatState, _owner: CombatUnit) -> void:
	pass
