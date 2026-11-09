class_name PlasmaTurret
extends BaseEnemy

## Floor 3, Normal. Cycles Chip -> Charge -> Plasma Burst. Charge aims the Burst without attacking.


func _init() -> void:
	var coords: Array[Vector2i] = [
		Vector2i(-1, -3), Vector2i(0, -3), Vector2i(1, -3), Vector2i(2, -3),
		Vector2i(-2, -2), Vector2i(-1, -2), Vector2i(0, -2), Vector2i(1, -2), Vector2i(2, -2), Vector2i(3, -2), Vector2i(4, -2), Vector2i(5, -2), Vector2i(6, -2),
		Vector2i(-2, -1), Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1), Vector2i(2, -1), Vector2i(3, -1), Vector2i(4, -1), Vector2i(5, -1), Vector2i(6, -1),
		Vector2i(-3, 0), Vector2i(-2, 0), Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0),
		Vector2i(-5, 1), Vector2i(-4, 1), Vector2i(-3, 1), Vector2i(-2, 1), Vector2i(-1, 1), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1),
		Vector2i(-5, 2), Vector2i(-4, 2), Vector2i(-3, 2), Vector2i(-2, 2), Vector2i(-1, 2), Vector2i(0, 2), Vector2i(1, 2),
		Vector2i(-6, 3), Vector2i(-5, 3), Vector2i(-4, 3), Vector2i(-3, 3), Vector2i(-2, 3), Vector2i(-1, 3), Vector2i(0, 3), Vector2i(1, 3),
	]
	super("Plasma Turret", CombatUnit.make_hex_health(coords))
	sprite = preload("res://assets/enemies/floor_3/plasma_turret.png")
	var chip: Array[BaseActionTile] = [
		DamageTile.new(Vector2i(0, -1)),
		DamageTile.new(Vector2i(-1, 0)),
		DamageTile.new(Vector2i(0, 0)),
		DamageTile.new(Vector2i(1, 0)),
	]
	var block: Array[BaseActionTile] = []
	for r in 3:
		for q in 5:
			block.append(DamageTile.new(Vector2i(q - floori(r / 2.0), r)))  # rows line up, not slant
	var burst := EnemyHit.new("Plasma Burst", "Hit 15 tiles in a 3x5 block.", block)
	burst.aimed = true
	actions = [
		EnemyHit.new("Chip", "Hit 4 tiles.", chip),
		EnemyWindUp.new("Charge", "No attack. Aims the next Plasma Burst.", burst),
		burst,
	]
	p1_cycle = [0, 1, 2]
