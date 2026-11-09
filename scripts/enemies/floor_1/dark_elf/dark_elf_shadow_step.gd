class_name DarkElfShadowStep
extends EnemyHit

## Block 5 + Hit 4: shields 5 random tiles of its own, then slashes 4 player tiles.

const SHIELDS := 5


func _init() -> void:
	var slash: Array[BaseActionTile] = [
		DamageTile.new(Vector2i(-1, 1)),
		DamageTile.new(Vector2i(-1, 0)),
		DamageTile.new(Vector2i(0, 0)),
		DamageTile.new(Vector2i(1, 0)),
	]
	super("Shadow Step", "Shield 5 random tiles of its own, then hit 4 tiles in a slash.", slash)
	extra_types = [Enum.BaseEnemyActionEnum.DEFEND]
	add_own_effect(ShieldTile, SHIELDS)


func execute(combat: CombatState, owner: CombatUnit) -> void:
	await inflict_random_own(combat, owner, ShieldTile.new(Vector2i.ZERO), SHIELDS)
	await super(combat, owner)
