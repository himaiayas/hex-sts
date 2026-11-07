class_name Griffin
extends BaseEnemy

## Floor 1, Normal.


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
	actions = []
