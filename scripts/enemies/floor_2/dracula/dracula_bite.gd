class_name DraculaBite
extends BaseEnemyAction

## Hit 8: two fang marks of 4, one hex apart. Then heals that many of its own damaged tiles
## (4 in P1, 8 in P2).

var heal: int


func _init(_heal: int) -> void:
	super(Enum.BaseEnemyActionEnum.ATTACK, "Bite", 1.0)
	description = "Hit 8 tiles in two fang marks, then heal %d of its own." % _heal
	heal = _heal
	add_own_effect(HealTile, heal)
	hit_vfx = preload("res://assets/enemies/floor_2/dracula_attack_bite.png")
	var fangs: Array[BaseActionTile] = []
	for x in [0, 3]:
		for c in [Vector2i(0, 0), Vector2i(-1, 1), Vector2i(0, 1), Vector2i(-1, 2)]:
			fangs.append(DamageTile.new(c + Vector2i(x, 0)))
	parts = [EnemyActionPart.new(Enum.Side.PLAYER, fangs)]


func execute(combat: CombatState, owner: CombatUnit) -> void:
	await GridAction.new(Enum.TargetType.PLAYER, parts[0].tiles).execute(combat, combat.player, parts[0].cell)
	await inflict_random_own(combat, owner, HealTile.new(Vector2i.ZERO), heal)
