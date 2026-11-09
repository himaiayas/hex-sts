class_name HackerAI
extends BaseEnemy

## Floor 3, Normal. Cycles Hack -> Lockdown -> System Crash. Firewall (a power): debuffs can't be put on it.


func _init() -> void:
	var coords: Array[Vector2i] = [
		Vector2i(-2, -6), Vector2i(-1, -6), Vector2i(0, -6), Vector2i(1, -6), Vector2i(2, -6), Vector2i(3, -6), Vector2i(4, -6), Vector2i(5, -6), Vector2i(6, -6),
		Vector2i(-3, -5), Vector2i(-2, -5), Vector2i(-1, -5), Vector2i(0, -5), Vector2i(1, -5), Vector2i(2, -5), Vector2i(3, -5), Vector2i(4, -5), Vector2i(5, -5), Vector2i(6, -5), Vector2i(7, -5), Vector2i(8, -5),
		Vector2i(-3, -4), Vector2i(-2, -4), Vector2i(6, -4), Vector2i(7, -4),
		Vector2i(-4, -3), Vector2i(-3, -3), Vector2i(6, -3), Vector2i(7, -3),
		Vector2i(-4, -2), Vector2i(-3, -2), Vector2i(5, -2), Vector2i(6, -2),
		Vector2i(-5, -1), Vector2i(-4, -1), Vector2i(5, -1), Vector2i(6, -1),
		Vector2i(-5, 0), Vector2i(-4, 0), Vector2i(-3, 0), Vector2i(-2, 0), Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0), Vector2i(4, 0), Vector2i(5, 0),
		Vector2i(-6, 1), Vector2i(-5, 1), Vector2i(-4, 1), Vector2i(-3, 1), Vector2i(-2, 1), Vector2i(-1, 1), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1), Vector2i(4, 1), Vector2i(5, 1),
		Vector2i(-1, 2),
		Vector2i(-2, 3), Vector2i(-1, 3),
		Vector2i(-2, 4),
		Vector2i(-5, 5), Vector2i(-4, 5), Vector2i(-3, 5), Vector2i(-2, 5), Vector2i(-1, 5), Vector2i(0, 5),
	]
	super("Hacker AI", CombatUnit.make_hex_health(coords))
	sprite = preload("res://assets/enemies/floor_3/hacker_ai.png")
	var crash: Array[BaseActionTile] = []
	for r in 2:
		for q in 4:
			crash.append(DamageTile.new(Vector2i(q - floori(r / 2.0), r)))  # rows line up, not slant
	var hack := EnemyApplyPower.new("Hack", "A random card in your next hand is Exhausted.", HackedPower.new(), true)
	hack.pose = preload("res://assets/enemies/floor_3/hacker_ai_hack.png")
	actions = [
		hack,
		EnemyApplyPower.new("Lockdown", "Your next card costs 1 more.", LockdownPower.new(), true),
		EnemyHit.new("System Crash", "Hit 8 tiles in 2 rows.", crash),
	]
	p1_cycle = [0, 1, 2]
	statuses.append(FirewallPower.new())
