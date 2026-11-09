class_name DarkElfShadowStep
extends EnemyHit

## Block 5 + Hit 5: shields 5 random tiles of its own, then slashes 5 player tiles.

const SHIELDS := 5


func _init() -> void:
	var slash: Array[BaseActionTile] = [
		DamageTile.new(Vector2i(-1, 1)),
		DamageTile.new(Vector2i(-1, 0)),
		DamageTile.new(Vector2i(0, 0)),
		DamageTile.new(Vector2i(1, 0)),
		DamageTile.new(Vector2i(1, -1)),
	]
	super("Shadow Step", "Shield 5 random tiles of its own, then hit 5 tiles in a slash.", slash)
	extra_types = [Enum.BaseEnemyActionEnum.DEFEND]


func execute(combat: CombatState, owner: CombatUnit) -> void:
	await inflict_random_own(combat, owner, ShieldTile.new(Vector2i.ZERO), SHIELDS)
	await super(combat, owner)
