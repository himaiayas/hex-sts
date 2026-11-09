class_name DragonClaw
extends BaseEnemyAction

## Hit HITS: the HITS best player tiles wherever they are, picked at plan time. Ties are random.

const HITS := 6


func _init() -> void:
	super(Enum.BaseEnemyActionEnum.ATTACK, "Claw", 1.0)
	description = "Hit the %d best tiles, wherever they are." % HITS
	hit_vfx = preload("res://assets/enemies/floor_1/dragon_attack_claw.png")
	parts = [EnemyActionPart.new(Enum.Side.PLAYER, [])]


func plan(combat: CombatState, owner: CombatUnit) -> void:
	var part := parts[0]
	var target := target_of(part, combat, owner)
	var one := EnemyActionPart.new(part.side, [DamageTile.new(Vector2i.ZERO)])
	var cells: Array[Vector2i] = []
	var scores := {}
	for cell in target.health:
		var score := score_cell(one, cell, target)
		if score > 0:  # damaged tiles aren't worth a hit
			cells.append(cell)
			scores[cell] = score
	cells.shuffle()
	cells.sort_custom(func(a: Vector2i, b: Vector2i) -> bool: return scores[a] > scores[b])
	part.cell = Vector2i.ZERO
	part.tiles = []
	for cell in cells.slice(0, HITS):
		part.tiles.append(DamageTile.new(cell))


func execute(combat: CombatState, _owner: CombatUnit) -> void:
	await GridAction.new(Enum.TargetType.PLAYER, parts[0].tiles).execute(combat, combat.player, parts[0].cell)
