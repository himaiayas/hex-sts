class_name Vermin
extends BaseEnemy

## Floor 1, Normal. Cycles Gnaw -> Gnaw -> Skitter.


func _init() -> void:
	var coords: Array[Vector2i] = [
		Vector2i(-3, -1), Vector2i(-2, -1), Vector2i(-1, -1), Vector2i(0, -1),
		Vector2i(-4, 0), Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0), Vector2i(4, 0),
		Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1),
		Vector2i(1, 2),
	]
	super("Vermin", CombatUnit.make_hex_health(coords))
	sprite = preload("res://assets/enemies/floor_1/vermin.png")
	var bite: Array[BaseActionTile] = [
		DamageTile.new(Vector2i(0, 0)),
		DamageTile.new(Vector2i(1, 0)),
		DamageTile.new(Vector2i(0, 1)),
	]
	actions = [
		EnemyHit.new("Gnaw", "Hit 3 tiles twice, scattered.", bite, 2),
		EnemyShieldSelf.new("Skitter", 5, "Shield 5 random tiles of its own."),
	]
	p1_cycle = [0, 0, 1]
