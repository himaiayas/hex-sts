class_name WerewolfHuman
extends EnemyHit

## Human form: Block 10 + Hit 5. Shields 10 random tiles of its own, then claws 5 player tiles.

const SHIELDS := 10


func _init() -> void:
	var claw: Array[BaseActionTile] = [
		DamageTile.new(Vector2i(-1, 0)),
		DamageTile.new(Vector2i(0, 0)),
		DamageTile.new(Vector2i(1, 0)),
		DamageTile.new(Vector2i(-1, 1)),
		DamageTile.new(Vector2i(0, 1)),
	]
	super("Guard", "Shield 10 random tiles of its own, then hit 5 tiles.", claw)
	extra_types = [Enum.BaseEnemyActionEnum.DEFEND]


func execute(combat: CombatState, owner: CombatUnit) -> void:
	await inflict_random_own(combat, owner, ShieldTile.new(Vector2i.ZERO), SHIELDS)
	await super(combat, owner)
