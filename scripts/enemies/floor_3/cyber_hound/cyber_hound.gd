class_name CyberHound
extends BaseEnemy

## Floor 3, Normal. Overclock: Bite once, then twice, then 3 times, and back to once.


func _init() -> void:
	var coords: Array[Vector2i] = [
		Vector2i(6, -4), Vector2i(7, -4), Vector2i(8, -4),
		Vector2i(-5, -3), Vector2i(-4, -3), Vector2i(-3, -3), Vector2i(5, -3), Vector2i(6, -3), Vector2i(7, -3),
		Vector2i(-4, -2), Vector2i(-3, -2), Vector2i(-2, -2), Vector2i(-1, -2), Vector2i(0, -2), Vector2i(1, -2), Vector2i(2, -2), Vector2i(3, -2), Vector2i(4, -2), Vector2i(5, -2), Vector2i(6, -2), Vector2i(7, -2),
		Vector2i(-4, -1), Vector2i(-3, -1), Vector2i(-2, -1), Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1), Vector2i(2, -1), Vector2i(3, -1), Vector2i(4, -1),
		Vector2i(-5, 0), Vector2i(-4, 0), Vector2i(-3, 0), Vector2i(-2, 0), Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0), Vector2i(4, 0),
		Vector2i(-4, 1), Vector2i(-3, 1), Vector2i(-2, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1),
		Vector2i(-5, 2), Vector2i(-3, 2), Vector2i(0, 2), Vector2i(2, 2),
		Vector2i(-5, 3), Vector2i(-4, 3), Vector2i(-3, 3), Vector2i(0, 3), Vector2i(1, 3), Vector2i(2, 3),
	]
	super("Cyber Hound", CombatUnit.make_hex_health(coords))
	sprite = preload("res://assets/enemies/floor_3/cyber_hound.png")
	# A jaw: rows of 4 and 3.
	var bite: Array[BaseActionTile] = []
	for q in 3:
		bite.append(DamageTile.new(Vector2i(q, 0)))
	for q in 2:
		bite.append(DamageTile.new(Vector2i(q - 1, 1)))
	actions = [
		EnemyHit.new("Bite", "Hit 5 tiles. Overclock: 1 more Bite next turn.", bite),
		EnemyHit.new("Bite", "Hit 5 tiles 2 times. Overclock: 1 more Bite next turn.", bite, 2),
		EnemyHit.new("Bite", "Hit 5 tiles 3 times. Overclock: back to 1 Bite next turn.", bite, 3),
	]
	p1_cycle = [0, 1, 2]
