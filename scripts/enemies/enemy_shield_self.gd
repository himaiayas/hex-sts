class_name EnemyShieldSelf
extends BaseEnemyAction

## Block X: shields X random undamaged tiles of its own, picked when it runs
## (Dracula's Blood Mist, Ramiel's Scan).

var amount: int


func _init(_name: String, _amount: int) -> void:
	super(Enum.BaseEnemyActionEnum.DEFEND, _name, 1.0)
	amount = _amount
	description = "Shield %d random tiles of its own." % amount


func execute(combat: CombatState, owner: CombatUnit) -> void:
	await inflict_random_own(combat, owner, ShieldTile.new(Vector2i.ZERO), amount)
