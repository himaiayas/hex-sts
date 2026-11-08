class_name Goblin
extends BaseEnemy

## Floor 1, Normal. Cycles Stab -> Backstab.


func _init() -> void:
	var coords: Array[Vector2i] = [
		Vector2i(-1, -2), Vector2i(0, -2), Vector2i(1, -2),
		Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1), Vector2i(2, -1),
		Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0),
		Vector2i(-2, 1), Vector2i(-1, 1), Vector2i(0, 1), Vector2i(1, 1),
		Vector2i(-2, 2), Vector2i(-1, 2), Vector2i(0, 2),
	]
	super("Goblin", CombatUnit.make_hex_health(coords))
	sprite = preload("res://assets/enemies/floor_1/goblin.png")
	var line: Array[BaseActionTile] = []
	for q in 5:
		line.append(DamageTile.new(Vector2i(q, 0)))
	var backstab: Array[BaseActionTile] = [
		DamageTile.new(Vector2i(0, 0), true),
		DamageTile.new(Vector2i(1, 0), true),
		DamageTile.new(Vector2i(0, 1), true),
	]
	actions = [
		EnemyHit.new("Stab", "Hit 5 tiles in a line.", line),
		EnemyHit.new("Backstab", "Hit 3 tiles with Pierce.", backstab),
	]
	p1_cycle = [0, 1]
