class_name Skeleton
extends BaseEnemy

## Floor 2, Normal.


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
	actions = []
