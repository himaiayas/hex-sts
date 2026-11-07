class_name Dracula
extends BaseEnemy

## Floor 2, Boss.


func _init() -> void:
	var coords: Array[Vector2i] = [
		Vector2i(4, -9), Vector2i(5, -9),
		Vector2i(3, -8), Vector2i(4, -8), Vector2i(5, -8),
		Vector2i(2, -7), Vector2i(3, -7), Vector2i(4, -7), Vector2i(5, -7),
		Vector2i(2, -6), Vector2i(3, -6), Vector2i(4, -6),
		Vector2i(2, -5), Vector2i(3, -5),
		Vector2i(1, -4), Vector2i(2, -4), Vector2i(3, -4),
		Vector2i(-4, -3), Vector2i(-3, -3), Vector2i(0, -3), Vector2i(1, -3), Vector2i(2, -3), Vector2i(3, -3), Vector2i(6, -3), Vector2i(7, -3),
		Vector2i(-5, -2), Vector2i(-4, -2), Vector2i(-3, -2), Vector2i(-1, -2), Vector2i(0, -2), Vector2i(1, -2), Vector2i(2, -2), Vector2i(3, -2), Vector2i(5, -2), Vector2i(6, -2), Vector2i(7, -2),
		Vector2i(-6, -1), Vector2i(-5, -1), Vector2i(-4, -1), Vector2i(-3, -1), Vector2i(-2, -1), Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1), Vector2i(2, -1), Vector2i(3, -1), Vector2i(4, -1), Vector2i(5, -1), Vector2i(6, -1), Vector2i(7, -1),
		Vector2i(-8, 0), Vector2i(-7, 0), Vector2i(-6, 0), Vector2i(-5, 0), Vector2i(-4, 0), Vector2i(-3, 0), Vector2i(-2, 0), Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0), Vector2i(4, 0), Vector2i(5, 0), Vector2i(6, 0), Vector2i(7, 0),
		Vector2i(-9, 1), Vector2i(-8, 1), Vector2i(-7, 1), Vector2i(-6, 1), Vector2i(-5, 1), Vector2i(-4, 1), Vector2i(-3, 1), Vector2i(-2, 1), Vector2i(-1, 1), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1), Vector2i(4, 1), Vector2i(5, 1), Vector2i(6, 1), Vector2i(7, 1), Vector2i(8, 1),
		Vector2i(-9, 2), Vector2i(-8, 2), Vector2i(-7, 2), Vector2i(-6, 2), Vector2i(-5, 2), Vector2i(-4, 2), Vector2i(-3, 2), Vector2i(-2, 2), Vector2i(-1, 2), Vector2i(0, 2), Vector2i(1, 2), Vector2i(2, 2), Vector2i(3, 2), Vector2i(4, 2), Vector2i(5, 2), Vector2i(6, 2), Vector2i(7, 2),
		Vector2i(-8, 3), Vector2i(-7, 3), Vector2i(-6, 3), Vector2i(-5, 3), Vector2i(-4, 3), Vector2i(-3, 3), Vector2i(-2, 3), Vector2i(-1, 3), Vector2i(0, 3), Vector2i(1, 3), Vector2i(2, 3), Vector2i(3, 3), Vector2i(4, 3), Vector2i(5, 3),
		Vector2i(-8, 4), Vector2i(-7, 4), Vector2i(-6, 4), Vector2i(-3, 4), Vector2i(-2, 4), Vector2i(-1, 4), Vector2i(2, 4), Vector2i(3, 4), Vector2i(4, 4),
		Vector2i(-8, 5), Vector2i(-7, 5), Vector2i(-3, 5), Vector2i(-2, 5), Vector2i(2, 5), Vector2i(3, 5),
	]
	super("Dracula", CombatUnit.make_hex_health(coords))
	idle_frames = [
		preload("res://assets/enemies/floor_2/dracula_idle1.png"),
		preload("res://assets/enemies/floor_2/dracula_idle2.png"),
		preload("res://assets/enemies/floor_2/dracula_idle3.png"),
	]
	actions = []
