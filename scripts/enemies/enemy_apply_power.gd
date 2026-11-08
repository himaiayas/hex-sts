class_name EnemyApplyPower
extends BaseEnemyAction

## Gives a power to the player (a debuff, like Screech) or to the enemy itself (a buff, like Strength).
## Each use applies a fresh copy, so it stacks the way the power does.

var power: BasePower
var on_player: bool


func _init(_name: String, _description: String, _power: BasePower, _on_player: bool) -> void:
	super(Enum.BaseEnemyActionEnum.DEBUFF if _on_player else Enum.BaseEnemyActionEnum.BUFF, _name, 1.0)
	description = _description
	power = _power
	on_player = _on_player


func execute(combat: CombatState, owner: CombatUnit) -> void:
	var target := combat.player if on_player else owner
	target.add_power(combat, power.copy())
	await combat.flush()
