class_name DraculaBloodMist
extends BaseEnemyAction

## Block 10: shields 10 random undamaged tiles of its own.

const SHIELDS := 10


func _init() -> void:
	super(Enum.BaseEnemyActionEnum.DEFEND, "Blood Mist", 1.0)


func execute(combat: CombatState, owner: CombatUnit) -> void:
	await inflict_random_own(combat, owner, ShieldTile.new(Vector2i.ZERO), SHIELDS)
