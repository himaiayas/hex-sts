class_name TerminatorRally
extends BaseEnemyAction

## Every living enemy, the Terminator included, gains RALLY Strength.

const RALLY := 1


func _init() -> void:
	super(Enum.BaseEnemyActionEnum.BUFF, "Rally", 1.0)
	description = "Every enemy gains %d Strength." % RALLY


func execute(combat: CombatState, _owner: CombatUnit) -> void:
	for enemy in combat.enemies:
		if not enemy.is_dead():
			enemy.add_power(combat, StrengthPower.new(RALLY))
	await combat.flush()
