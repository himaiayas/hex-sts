class_name Mummy
extends BaseEnemy

## Floor 2, Normal. Cycles Curse Wrap -> Pierce. Wrapped: the first Attack card each player turn
## deals it half damage.

const CURSE_WRAP := 3


func _init() -> void:
	var coords: Array[Vector2i] = [
		Vector2i(-3, -3), Vector2i(-2, -3), Vector2i(-1, -3), Vector2i(0, -3), Vector2i(1, -3), Vector2i(2, -3), Vector2i(3, -3),
		Vector2i(-3, -2), Vector2i(-2, -2), Vector2i(-1, -2), Vector2i(0, -2), Vector2i(1, -2), Vector2i(2, -2), Vector2i(3, -2),
		Vector2i(-3, -1), Vector2i(-2, -1), Vector2i(0, -1), Vector2i(2, -1), Vector2i(3, -1),
		Vector2i(-3, 0), Vector2i(-2, 0), Vector2i(-1, 0), Vector2i(0, 0), Vector2i(2, 0), Vector2i(3, 0),
		Vector2i(-3, 1), Vector2i(-2, 1), Vector2i(0, 1), Vector2i(2, 1), Vector2i(3, 1),
		Vector2i(-3, 2), Vector2i(-2, 2), Vector2i(-1, 2), Vector2i(0, 2), Vector2i(1, 2), Vector2i(2, 2), Vector2i(3, 2),
		Vector2i(-3, 3), Vector2i(-2, 3), Vector2i(-1, 3), Vector2i(0, 3), Vector2i(1, 3), Vector2i(2, 3), Vector2i(3, 3),
	]
	super("Mummy", CombatUnit.make_hex_health(coords))
	sprite = preload("res://assets/enemies/floor_2/mummy.png")
	var lance: Array[BaseActionTile] = []
	for r in 2:
		for q in 4:
			lance.append(DamageTile.new(Vector2i(q, r), r == 0))  # only the first row pierces
	actions = [
		EnemyApplyPower.new("Curse Wrap", "Your next Defense card places %d fewer Shield or Plate." % CURSE_WRAP, CurseWrapPower.new(CURSE_WRAP), true),
		EnemyHit.new("Pierce", "Hit 8 tiles in 2 rows; the first row has Pierce.", lance),
	]
	p1_cycle = [0, 1]
	statuses.append(WrappedPower.new())
