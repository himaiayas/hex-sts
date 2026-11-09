class_name DragonFireBreath
extends BaseEnemyAction

## Hit 10 in a cone, narrow end up-right toward the Dragon. In P2 it's Inferno: the 3 tiles at the
## cone's tip pierce (only those, so Pierce stays rare).


func _init(pierce := false) -> void:
	super(Enum.BaseEnemyActionEnum.ATTACK, "Inferno" if pierce else "Fire Breath", 1.0)
	heavy_impact = true
	description = "Hit 10 tiles in a cone; the 3 at its tip have Pierce." if pierce else "Hit 10 tiles in a cone."
	pose = preload("res://assets/enemies/floor_1/dragon_attack_fire_breath.png")
	var cone: Array[BaseActionTile] = []
	# One diagonal per width, 2 to 5 tiles.
	for q in 4:
		for r in q + 1:
			cone.append(DamageTile.new(Vector2i(-q, r), pierce and q < 2))  # the tip: 1 + 2 tiles
	parts = [EnemyActionPart.new(Enum.Side.PLAYER, cone)]


func execute(combat: CombatState, _owner: CombatUnit) -> void:
	await GridAction.new(Enum.TargetType.PLAYER, parts[0].tiles).execute(combat, combat.player, parts[0].cell)
