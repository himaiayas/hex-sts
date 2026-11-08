class_name Zombie
extends BaseEnemy

## Floor 2, Normal. Cycles Lumber -> Groan -> Rot Bite. Rise: the first time it dies, it comes back
## with RISE tiles.

const RISE := 12


func _init() -> void:
	var coords: Array[Vector2i] = [
		Vector2i(-1, -3), Vector2i(0, -3), Vector2i(1, -3), Vector2i(2, -3),
		Vector2i(-3, -2), Vector2i(-2, -2), Vector2i(-1, -2), Vector2i(0, -2), Vector2i(1, -2), Vector2i(2, -2),
		Vector2i(-3, -1), Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1), Vector2i(2, -1), Vector2i(3, -1),
		Vector2i(-3, 0), Vector2i(-2, 0), Vector2i(-1, 0), Vector2i(0, 0), Vector2i(2, 0), Vector2i(3, 0),
		Vector2i(-3, 1), Vector2i(-2, 1), Vector2i(-1, 1), Vector2i(0, 1), Vector2i(1, 1), Vector2i(3, 1),
		Vector2i(-2, 2), Vector2i(-1, 2), Vector2i(0, 2), Vector2i(1, 2), Vector2i(2, 2), Vector2i(3, 2),
		Vector2i(-3, 3), Vector2i(-2, 3), Vector2i(0, 3), Vector2i(1, 3), Vector2i(2, 3), Vector2i(3, 3),
	]
	super("Zombie", CombatUnit.make_hex_health(coords))
	sprite = preload("res://assets/enemies/floor_2/zombie.png")
	var lumber: Array[BaseActionTile] = [DamageTile.new(Vector2i.ZERO)]
	for c: Vector2i in [Vector2i(1, 0), Vector2i(1, -1), Vector2i(0, -1), Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, 1), Vector2i(2, -1), Vector2i(2, 0)]:
		lumber.append(DamageTile.new(c))
	# Two rows of 3, with Poison on the tile past each end.
	var rot_bite: Array[BaseActionTile] = []
	for c: Vector2i in [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(-1, 1), Vector2i(0, 1), Vector2i(1, 1)]:
		rot_bite.append(DamageTile.new(c))
	for c: Vector2i in [Vector2i(3, 0), Vector2i(-2, 1)]:
		rot_bite.append(ApplyEffectTile.new(c, PoisonTileEffect.new()))
	actions = [
		EnemyHit.new("Lumber", "Hit 9 tiles in a cluster.", lumber),
		EnemyShieldSelf.new("Groan", 6, "Shield 6 random tiles of its own."),
		EnemyHit.new("Rot Bite", "Hit 6 tiles and Poison the 2 tiles past its ends.", rot_bite),
	]
	p1_cycle = [0, 1, 2]
	statuses.append(RisePower.new(RISE))
