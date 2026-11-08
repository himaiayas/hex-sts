class_name LilGhost
extends BaseEnemy

## Floor 2, Normal. Cycles Boo -> Shiver. Ethereal: one Attack card lands at most ETHEREAL hits on it.

const ETHEREAL := 5


func _init() -> void:
	var coords: Array[Vector2i] = [
		Vector2i(2, -4), Vector2i(3, -4),
		Vector2i(1, -3), Vector2i(2, -3), Vector2i(3, -3),
		Vector2i(0, -2), Vector2i(3, -2),
		Vector2i(0, -1), Vector2i(1, -1), Vector2i(2, -1),
		Vector2i(-2, 0), Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0),
		Vector2i(-1, 1), Vector2i(0, 1), Vector2i(1, 1),
		Vector2i(-2, 2), Vector2i(-1, 2), Vector2i(0, 2), Vector2i(1, 2),
		Vector2i(-2, 3), Vector2i(-1, 3), Vector2i(0, 3),
	]
	super("Lil Ghost", CombatUnit.make_hex_health(coords))
	sprite = preload("res://assets/enemies/floor_2/lil_ghost.png")
	var boo: Array[BaseActionTile] = [
		DamageTile.new(Vector2i(0, 0)),
		DamageTile.new(Vector2i(1, 0)),
		DamageTile.new(Vector2i(-1, 1)),
		DamageTile.new(Vector2i(0, 1)),
	]
	actions = [
		EnemyHit.new("Boo", "Hit 4 tiles 3 times.", boo, 3),
		EnemyApplyPower.new("Shiver", "Your next card costs 1 more.", ShiverPower.new(), true),
	]
	p1_cycle = [0, 1]
	statuses.append(EtherealPower.new(ETHEREAL))
