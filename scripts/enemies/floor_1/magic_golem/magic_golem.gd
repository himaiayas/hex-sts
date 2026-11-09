class_name MagicGolem
extends BaseEnemy

## Floor 1, Normal. Cycles Arcane Bolt -> Charge -> Overload. Starts with RUNE_START
## Shields, and the Rune Armor power shields RUNE_EVERY_TURN more at the start of each of its turns.

const RUNE_START := 10
const RUNE_EVERY_TURN := 5


func _init() -> void:
	var coords: Array[Vector2i] = [
		Vector2i(1, -3),
		Vector2i(-1, -2), Vector2i(0, -2), Vector2i(1, -2), Vector2i(2, -2),
		Vector2i(-2, -1), Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1), Vector2i(2, -1), Vector2i(3, -1),
		Vector2i(-3, 0), Vector2i(-2, 0), Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0),
		Vector2i(-4, 1), Vector2i(-3, 1), Vector2i(1, 1), Vector2i(2, 1),
		Vector2i(-4, 2), Vector2i(-3, 2), Vector2i(-2, 2), Vector2i(0, 2), Vector2i(1, 2),
		Vector2i(-5, 3), Vector2i(-4, 3), Vector2i(-3, 3), Vector2i(-2, 3), Vector2i(-1, 3), Vector2i(0, 3),
		Vector2i(-4, 4), Vector2i(-3, 4), Vector2i(-2, 4), Vector2i(-1, 4),
		Vector2i(-3, 5),
	]
	super("Magic Golem", CombatUnit.make_hex_health(coords))
	sprite = preload("res://assets/enemies/floor_1/magic_golem.png")
	var ring: Array[BaseActionTile] = []
	for dir: Vector2i in [Vector2i(1, 0), Vector2i(1, -1), Vector2i(0, -1), Vector2i(-1, 0)]:
		ring.append(DamageTile.new(dir))
	# Rows of 3, 4, 4 and 3: each row's first and last q.
	var blob: Array[BaseActionTile] = []
	var rows: Array[Vector2i] = [Vector2i(0, 2), Vector2i(-1, 2), Vector2i(-1, 1)]
	for r in rows.size():
		for q in range(rows[r].x, rows[r].y + 1):
			blob.append(DamageTile.new(Vector2i(q, r)))
	actions = [
		EnemyHit.new("Arcane Bolt", "Hit 4 tiles in an arc.", ring),
		EnemyShieldSelf.new("Charge", 8, "Shield 8 random tiles of its own."),
		EnemyHit.new("Overload", "Hit 10 tiles in a big blob.", blob),
	]
	p1_cycle = [0, 1, 2]
	var cells := health.keys()
	cells.shuffle()
	for cell in cells.slice(0, RUNE_START):
		health[cell].hp = Enum.HealthTileEnum.SHIELDED
	statuses.append(RuneArmorPower.new(RUNE_EVERY_TURN))
