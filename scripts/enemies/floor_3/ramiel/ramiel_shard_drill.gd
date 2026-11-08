class_name RamielShardDrill
extends BaseEnemyAction

## Hit 8 x3 (P2): three 8-hex lines, one along each hex axis, each on a random spot
## the earlier ones don't already hit.


func _init() -> void:
	super(Enum.BaseEnemyActionEnum.ATTACK, "Shard Drill", 1.0)
	for dir in [Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, -1)]:
		var line: Array[BaseActionTile] = []
		for k in 8:
			line.append(DamageTile.new(dir * k))
		parts.append(EnemyActionPart.new(Enum.Side.PLAYER, line))


func pick_cell(part: EnemyActionPart, target: CombatUnit) -> Vector2i:
	return pick_random_cell(part, target)


func execute(combat: CombatState, _owner: CombatUnit) -> void:
	for part in parts:
		await GridAction.new(Enum.TargetType.PLAYER, part.tiles).execute(combat, combat.player, part.cell)
