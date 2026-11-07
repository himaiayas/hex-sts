class_name Bat
extends BaseEnemy

## Floor 2, Normal.


func _init() -> void:
	var coords: Array[Vector2i] = [
		Vector2i(0, -2), Vector2i(2, -2),
		Vector2i(-4, -1), Vector2i(-3, -1), Vector2i(-2, -1), Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1), Vector2i(2, -1), Vector2i(3, -1), Vector2i(4, -1),
		Vector2i(-4, 0), Vector2i(-3, 0), Vector2i(-2, 0), Vector2i(0, 0), Vector2i(2, 0), Vector2i(3, 0), Vector2i(4, 0),
		Vector2i(-5, 1), Vector2i(-4, 1), Vector2i(-1, 1), Vector2i(0, 1), Vector2i(3, 1), Vector2i(4, 1),
	]
	super("Bat", CombatUnit.make_hex_health(coords))
	sprite = preload("res://assets/enemies/floor_2/bat.png")
	actions = []
