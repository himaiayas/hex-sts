class_name AndroidSentinel
extends BaseEnemy

## Floor 3, Normal. Cycles Aim -> Snipe. Aim locks where the Snipe lands without attacking.


func _init() -> void:
	var coords: Array[Vector2i] = [
		Vector2i(2, -6), Vector2i(3, -6),
		Vector2i(1, -5), Vector2i(2, -5), Vector2i(3, -5),
		Vector2i(1, -4), Vector2i(2, -4),
		Vector2i(-2, -3), Vector2i(-1, -3), Vector2i(0, -3), Vector2i(1, -3), Vector2i(2, -3), Vector2i(3, -3), Vector2i(4, -3),
		Vector2i(-3, -2), Vector2i(-2, -2), Vector2i(-1, -2), Vector2i(0, -2), Vector2i(1, -2), Vector2i(2, -2), Vector2i(3, -2), Vector2i(4, -2), Vector2i(5, -2),
		Vector2i(-3, -1), Vector2i(-2, -1), Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1), Vector2i(2, -1), Vector2i(3, -1),
		Vector2i(-4, 0), Vector2i(-3, 0), Vector2i(-2, 0), Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0), Vector2i(4, 0),
		Vector2i(-4, 1), Vector2i(-3, 1), Vector2i(-2, 1), Vector2i(-1, 1), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1),
		Vector2i(-3, 2), Vector2i(-2, 2), Vector2i(-1, 2), Vector2i(0, 2),
		Vector2i(-3, 3), Vector2i(-1, 3),
		Vector2i(-4, 4), Vector2i(-3, 4), Vector2i(-2, 4), Vector2i(-1, 4),
		Vector2i(-4, 5), Vector2i(-2, 5),
		Vector2i(-5, 6), Vector2i(-4, 6), Vector2i(-3, 6), Vector2i(-2, 6),
	]
	super("Android Sentinel", CombatUnit.make_hex_health(coords))
	sprite = preload("res://assets/enemies/floor_3/android_sentinel.png")
	var line: Array[BaseActionTile] = []
	for q in 7:
		line.append(DamageTile.new(Vector2i(q, 0), q < 4))  # only the first 4 pierce
	var snipe := EnemyHit.new("Snipe", "Hit 7 tiles in a line; the first 4 have Pierce.", line)
	snipe.aimed = true
	actions = [EnemyWindUp.new("Aim", "No attack. Aims the next Snipe.", snipe), snipe]
	p1_cycle = [0, 1]
