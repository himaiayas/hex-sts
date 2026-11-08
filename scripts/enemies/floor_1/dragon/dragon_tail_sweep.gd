class_name DragonTailSweep
extends BaseEnemyAction

## Hit 6 x2: two rows of 6. The first goes on the best row, the second on the best row
## after the first one has landed.

var _first_hits: Array[Vector2i] = []


func _init() -> void:
	super(Enum.BaseEnemyActionEnum.ATTACK, "Tail Sweep", 1.0)
	description = "Hit 2 rows of 6 tiles."
	hit_vfx = preload("res://assets/enemies/floor_1/dragon_attack_tail_sweep.png")
	for i in 2:
		var row: Array[BaseActionTile] = []
		for q in 6:
			row.append(DamageTile.new(Vector2i(q, 0)))
		parts.append(EnemyActionPart.new(Enum.Side.PLAYER, row))


func plan(combat: CombatState, owner: CombatUnit) -> void:
	var target := target_of(parts[0], combat, owner)
	_first_hits.clear()
	parts[0].cell = pick_cell(parts[0], target)
	for t in parts[0].tiles:
		_first_hits.append(parts[0].cell + t.coords)
	parts[1].cell = pick_cell(parts[1], target)


## For the second row, a tile the first row covers scores as it will be after that hit:
## a Shield is broken (the tile is open again), anything else is damaged.
func score_cell(part: EnemyActionPart, cell: Vector2i, target: CombatUnit) -> int:
	if part == parts[0]:
		return super(part, cell, target)
	var score := 0
	for t in part.tiles:
		var c := cell + t.coords
		var tile: HealthTile = target.health.get(c)
		if tile == null:
			continue
		if c in _first_hits:
			if tile.hp == Enum.HealthTileEnum.SHIELDED:
				score += 3 if tile.has_effect(PlateTileEffect) else 2
		else:
			score += super(EnemyActionPart.new(part.side, [t]), cell, target)
	return score


func execute(combat: CombatState, _owner: CombatUnit) -> void:
	for part in parts:
		await GridAction.new(Enum.TargetType.PLAYER, part.tiles).execute(combat, combat.player, part.cell)
