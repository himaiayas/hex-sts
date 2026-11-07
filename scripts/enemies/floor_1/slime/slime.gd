class_name Slime
extends BaseEnemy

## Floor 1, Normal. Cycles Splat -> Goo.


func _init() -> void:
	var coords: Array[Vector2i] = [
		Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1), Vector2i(2, -1),
		Vector2i(-2, 0), Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0),
		Vector2i(-2, 1), Vector2i(-1, 1), Vector2i(0, 1), Vector2i(1, 1),
	]
	super("Slime", CombatUnit.make_hex_health(coords))
	sprite = preload("res://assets/enemies/floor_1/slime.png")
	var splat: Array[BaseActionTile] = [
		DamageTile.new(Vector2i(0, 0)),
		DamageTile.new(Vector2i(1, 0)),
		DamageTile.new(Vector2i(-1, 1)),
		DamageTile.new(Vector2i(0, 1)),
	]
	actions = [
		EnemyHit.new("Splat", "Hit 4 tiles in a blob.", splat),
		EnemyShieldSelf.new("Goo", 4, "Shield 4 random tiles of its own."),
	]
	p1_cycle = [0, 1]
