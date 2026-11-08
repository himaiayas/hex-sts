class_name Frangenstein
extends BaseEnemy

## Floor 2, Elite. Cycles Thunder Fist -> Static -> Overcharge. Stitched: starts with Plate on
## STITCHED random tiles.

const STITCHED := 15
const OVERCHARGE := 2


func _init() -> void:
	var coords: Array[Vector2i] = [
		Vector2i(2, -6), Vector2i(3, -6), Vector2i(4, -6),
		Vector2i(0, -5), Vector2i(1, -5), Vector2i(2, -5), Vector2i(3, -5), Vector2i(4, -5), Vector2i(5, -5),
		Vector2i(1, -4), Vector2i(2, -4), Vector2i(3, -4),
		Vector2i(-2, -3), Vector2i(-1, -3), Vector2i(0, -3), Vector2i(1, -3), Vector2i(2, -3), Vector2i(3, -3), Vector2i(4, -3), Vector2i(5, -3),
		Vector2i(-3, -2), Vector2i(-2, -2), Vector2i(-1, -2), Vector2i(0, -2), Vector2i(1, -2), Vector2i(2, -2), Vector2i(3, -2), Vector2i(4, -2), Vector2i(5, -2),
		Vector2i(-3, -1), Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1), Vector2i(2, -1), Vector2i(4, -1),
		Vector2i(-4, 0), Vector2i(-3, 0), Vector2i(-2, 0), Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0), Vector2i(4, 0),
		Vector2i(-4, 1), Vector2i(-2, 1), Vector2i(-1, 1), Vector2i(0, 1), Vector2i(1, 1), Vector2i(3, 1),
		Vector2i(-5, 2), Vector2i(-4, 2), Vector2i(-3, 2), Vector2i(-2, 2), Vector2i(0, 2), Vector2i(1, 2), Vector2i(2, 2), Vector2i(3, 2),
		Vector2i(-3, 3), Vector2i(-2, 3), Vector2i(-1, 3), Vector2i(0, 3),
		Vector2i(-4, 4), Vector2i(-3, 4), Vector2i(-1, 4), Vector2i(0, 4),
		Vector2i(-4, 5), Vector2i(-3, 5), Vector2i(-2, 5), Vector2i(-1, 5),
	]
	super("Frangenstein", CombatUnit.make_hex_health(coords))
	sprite = preload("res://assets/enemies/floor_2/frangenstein.png")
	var fist: Array[BaseActionTile] = []
	for r in 3:
		for q in 5:
			fist.append(DamageTile.new(Vector2i(q - floori(r / 2.0), r)))  # rows line up, not slant
	# A zigzag bolt down the grid.
	var bolt: Array[BaseActionTile] = []
	for c: Vector2i in [Vector2i(1, -2), Vector2i(1, -1), Vector2i(0, 0), Vector2i(0, 1), Vector2i(-1, 2)]:
		bolt.append(DamageTile.new(c, true))
	actions = [
		EnemyHit.new("Thunder Fist", "Hit 15 tiles in a 3x5 block.", fist),
		EnemyHit.new("Static", "Hit 5 tiles in a zigzag with Pierce.", bolt),
		EnemyApplyPower.new("Overcharge", "Gain %d Strength." % OVERCHARGE, StrengthPower.new(OVERCHARGE), false),
	]
	p1_cycle = [0, 1, 2]
	var cells := health.keys()
	cells.shuffle()
	for cell in cells.slice(0, STITCHED):
		health[cell].status_effects.append(PlateTileEffect.new())
