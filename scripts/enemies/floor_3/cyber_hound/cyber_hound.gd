class_name CyberHound
extends BaseEnemy

## Floor 3, Normal.


func _init() -> void:
	var coords: Array[Vector2i] = [
		Vector2i(6, -4), Vector2i(7, -4), Vector2i(8, -4),
		Vector2i(-5, -3), Vector2i(-4, -3), Vector2i(-3, -3), Vector2i(5, -3), Vector2i(6, -3), Vector2i(7, -3),
		Vector2i(-4, -2), Vector2i(-3, -2), Vector2i(-2, -2), Vector2i(-1, -2), Vector2i(0, -2), Vector2i(1, -2), Vector2i(2, -2), Vector2i(3, -2), Vector2i(4, -2), Vector2i(5, -2), Vector2i(6, -2), Vector2i(7, -2),
		Vector2i(-4, -1), Vector2i(-3, -1), Vector2i(-2, -1), Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1), Vector2i(2, -1), Vector2i(3, -1), Vector2i(4, -1),
		Vector2i(-5, 0), Vector2i(-4, 0), Vector2i(-3, 0), Vector2i(-2, 0), Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0), Vector2i(4, 0),
		Vector2i(-4, 1), Vector2i(-3, 1), Vector2i(-2, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1),
		Vector2i(-5, 2), Vector2i(-3, 2), Vector2i(0, 2), Vector2i(2, 2),
		Vector2i(-5, 3), Vector2i(-4, 3), Vector2i(-3, 3), Vector2i(0, 3), Vector2i(1, 3), Vector2i(2, 3),
	]
	super("Cyber Hound", CombatUnit.make_hex_health(coords))
	sprite = preload("res://assets/enemies/floor_3/cyber_hound.png")
	actions = []
