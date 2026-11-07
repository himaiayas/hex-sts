class_name Lich
extends BaseEnemy

## Floor 2, Elite.


func _init() -> void:
	var coords: Array[Vector2i] = [
		Vector2i(3, -8),
		Vector2i(2, -7), Vector2i(3, -7),
		Vector2i(1, -6), Vector2i(2, -6), Vector2i(3, -6),
		Vector2i(1, -5), Vector2i(2, -5), Vector2i(7, -5),
		Vector2i(0, -4), Vector2i(1, -4), Vector2i(2, -4), Vector2i(6, -4), Vector2i(7, -4),
		Vector2i(-1, -3), Vector2i(0, -3), Vector2i(1, -3), Vector2i(2, -3), Vector2i(6, -3),
		Vector2i(-2, -2), Vector2i(-1, -2), Vector2i(0, -2), Vector2i(1, -2), Vector2i(2, -2), Vector2i(5, -2), Vector2i(6, -2),
		Vector2i(-2, -1), Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1), Vector2i(2, -1), Vector2i(3, -1), Vector2i(4, -1), Vector2i(5, -1),
		Vector2i(-3, 0), Vector2i(-2, 0), Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0), Vector2i(4, 0), Vector2i(5, 0),
		Vector2i(-3, 1), Vector2i(-2, 1), Vector2i(-1, 1), Vector2i(0, 1), Vector2i(4, 1),
		Vector2i(-4, 2), Vector2i(-3, 2), Vector2i(-2, 2), Vector2i(-1, 2), Vector2i(0, 2), Vector2i(3, 2), Vector2i(4, 2),
		Vector2i(-6, 3), Vector2i(-5, 3), Vector2i(-4, 3), Vector2i(-3, 3), Vector2i(-2, 3), Vector2i(-1, 3), Vector2i(0, 3), Vector2i(1, 3), Vector2i(3, 3),
		Vector2i(-6, 4), Vector2i(-5, 4), Vector2i(-4, 4), Vector2i(-3, 4), Vector2i(-2, 4), Vector2i(-1, 4), Vector2i(0, 4), Vector2i(2, 4), Vector2i(3, 4),
		Vector2i(-6, 5), Vector2i(-5, 5), Vector2i(-4, 5), Vector2i(-3, 5), Vector2i(-2, 5), Vector2i(-1, 5), Vector2i(2, 5),
		Vector2i(1, 6), Vector2i(2, 6),
	]
	super("Lich", CombatUnit.make_hex_health(coords))
	actions = []
