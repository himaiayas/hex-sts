class_name Skeleton
extends BaseEnemy

## Floor 2, Normal. Cycles Bone Throw -> Rattle. Bone Armor: starts with BONE_ARMOR Shields.

const BONE_ARMOR := 8


func _init() -> void:
	var coords: Array[Vector2i] = [
		Vector2i(0, -3),
		Vector2i(-5, -2), Vector2i(-4, -2), Vector2i(-3, -2), Vector2i(-2, -2), Vector2i(-1, -2), Vector2i(0, -2), Vector2i(1, -2), Vector2i(2, -2), Vector2i(3, -2), Vector2i(4, -2), Vector2i(5, -2),
		Vector2i(0, -1),
		Vector2i(-5, 0), Vector2i(-4, 0), Vector2i(-3, 0), Vector2i(-2, 0), Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0), Vector2i(4, 0), Vector2i(5, 0),
		Vector2i(0, 1),
		Vector2i(-5, 2), Vector2i(-4, 2), Vector2i(-3, 2), Vector2i(-2, 2), Vector2i(-1, 2), Vector2i(0, 2), Vector2i(1, 2), Vector2i(2, 2), Vector2i(3, 2), Vector2i(4, 2), Vector2i(5, 2),
		Vector2i(0, 3),
		Vector2i(0, 4),
	]
	super("Skeleton", CombatUnit.make_hex_health(coords))
	sprite = preload("res://assets/enemies/floor_2/skeleton.png")
	var bone: Array[BaseActionTile] = [
		DamageTile.new(Vector2i(-1, 1)),
		DamageTile.new(Vector2i(0, 0)),
		DamageTile.new(Vector2i(1, 0)),
		DamageTile.new(Vector2i(2, 0)),
	]
	actions = [
		EnemyHit.new("Bone Throw", "Hit 4 tiles 2 times.", bone, 2),
		SkeletonRattle.new(),
	]
	p1_cycle = [0, 1]
	var cells := health.keys()
	cells.shuffle()
	for cell in cells.slice(0, BONE_ARMOR):
		health[cell].hp = Enum.HealthTileEnum.SHIELDED
