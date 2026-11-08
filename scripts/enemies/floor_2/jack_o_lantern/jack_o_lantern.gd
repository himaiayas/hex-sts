class_name JackOLantern
extends BaseEnemy

## Floor 2, Normal. Cycles Flame Spit -> Grin -> Pumpkin Smash. Burning Head: an Attack card that
## destroys 6 of its tiles gets BURN hits back.

const BURN := 3
const GRIN := 2


func _init() -> void:
	var coords: Array[Vector2i] = [
		Vector2i(2, -5), Vector2i(3, -5),
		Vector2i(2, -4),
		Vector2i(1, -3), Vector2i(2, -3),
		Vector2i(-1, -2), Vector2i(0, -2), Vector2i(1, -2), Vector2i(2, -2), Vector2i(3, -2),
		Vector2i(-3, -1), Vector2i(-2, -1), Vector2i(0, -1), Vector2i(1, -1), Vector2i(3, -1), Vector2i(4, -1),
		Vector2i(-3, 0), Vector2i(-2, 0), Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0),
		Vector2i(-4, 1), Vector2i(-3, 1), Vector2i(-2, 1), Vector2i(-1, 1), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1),
		Vector2i(-4, 2), Vector2i(-3, 2), Vector2i(1, 2), Vector2i(2, 2),
		Vector2i(-4, 3), Vector2i(-3, 3), Vector2i(-2, 3), Vector2i(-1, 3), Vector2i(0, 3), Vector2i(1, 3),
		Vector2i(-4, 4), Vector2i(-3, 4), Vector2i(-2, 4), Vector2i(-1, 4), Vector2i(0, 4),
	]
	super("Jack O'Lantern", CombatUnit.make_hex_health(coords))
	sprite = preload("res://assets/enemies/floor_2/jack_o_lantern.png")
	# A cone 3 then 4 wide, with Poison on 2 tiles past its wide end.
	var spit: Array[BaseActionTile] = []
	for q in 2:
		for r in q + 3:
			spit.append(DamageTile.new(Vector2i(-q, r)))
	for c: Vector2i in [Vector2i(-2, 1), Vector2i(-2, 2)]:
		spit.append(ApplyEffectTile.new(c, PoisonTileEffect.new()))
	# Rows of 3, 4 and 4: each row's first and last q.
	var smash: Array[BaseActionTile] = []
	var rows: Array[Vector2i] = [Vector2i(0, 2), Vector2i(-1, 2), Vector2i(-2, 1)]
	for r in rows.size():
		for q in range(rows[r].x, rows[r].y + 1):
			smash.append(DamageTile.new(Vector2i(q, r)))
	actions = [
		EnemyHit.new("Flame Spit", "Hit 7 tiles in a cone and Poison 2 tiles past it.", spit),
		EnemyApplyPower.new("Grin", "Gain %d Strength." % GRIN, StrengthPower.new(GRIN), false),
		EnemyHit.new("Pumpkin Smash", "Hit 11 tiles in a blob.", smash),
	]
	p1_cycle = [0, 1, 2]
	statuses.append(BurningHeadPower.new(BURN))
