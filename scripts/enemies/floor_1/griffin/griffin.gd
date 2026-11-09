class_name Griffin
extends BaseEnemy

## Floor 1, Normal. Cycles Talon -> Wing Gust -> Dive. Aerial (a power): the first AERIAL hits
## it takes each player turn miss.

const AERIAL := 3


func _init() -> void:
	var coords: Array[Vector2i] = [
		Vector2i(2, -4),
		Vector2i(1, -3), Vector2i(2, -3),
		Vector2i(1, -2),
		Vector2i(-5, -1), Vector2i(-4, -1), Vector2i(-3, -1), Vector2i(-2, -1), Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1), Vector2i(2, -1), Vector2i(3, -1), Vector2i(4, -1), Vector2i(5, -1), Vector2i(6, -1),
		Vector2i(-5, 0), Vector2i(-4, 0), Vector2i(-3, 0), Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0), Vector2i(3, 0), Vector2i(4, 0), Vector2i(5, 0),
		Vector2i(-2, 1), Vector2i(-1, 1), Vector2i(0, 1),
		Vector2i(-2, 2), Vector2i(-1, 2), Vector2i(0, 2),
		Vector2i(-2, 3), Vector2i(-1, 3),
		Vector2i(-2, 4),
	]
	super("Griffin", CombatUnit.make_hex_health(coords))
	sprite = preload("res://assets/enemies/floor_1/griffin.png")
	var talon: Array[BaseActionTile] = [
		DamageTile.new(Vector2i(-1, 0)),
		DamageTile.new(Vector2i(0, 0)),
		DamageTile.new(Vector2i(-1, 1)),
		DamageTile.new(Vector2i(0, 1)),
	]
	# An H: two columns of 3 with a gap between, joined by one tile in the middle row.
	var dive: Array[BaseActionTile] = []
	for r in 3:
		for q in 3:
			if q != 1 or r == 1:
				dive.append(DamageTile.new(Vector2i(q - floori(r / 2.0), r)))  # rows line up, not slant
	actions = [
		EnemyHit.new("Talon", "Hit 4 tiles 2 times.", talon, 2),
		EnemyShieldSelf.new("Wing Gust", 6, "Shield 6 random tiles of its own."),
		EnemyHit.new("Dive", "Hit 7 tiles in an H.", dive),
	]
	p1_cycle = [0, 1, 2]
	statuses.append(AerialPower.new(AERIAL))
