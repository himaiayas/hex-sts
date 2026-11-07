class_name Goblin
extends BaseEnemy

## Floor 1, Normal.


func _init() -> void:
	var coords: Array[Vector2i] = [
		Vector2i(-1, -2), Vector2i(0, -2), Vector2i(1, -2),
		Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1), Vector2i(2, -1),
		Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0),
		Vector2i(-2, 1), Vector2i(-1, 1), Vector2i(0, 1), Vector2i(1, 1),
		Vector2i(-2, 2), Vector2i(-1, 2), Vector2i(0, 2),
	]
	super("Goblin", CombatUnit.make_hex_health(coords))
	sprite = preload("res://assets/enemies/floor_1/goblin.png")
	actions = []
