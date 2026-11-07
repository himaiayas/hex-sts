class_name Vermin
extends BaseEnemy

## Floor 1, Normal.


func _init() -> void:
	var coords: Array[Vector2i] = [
		Vector2i(-3, -1), Vector2i(-2, -1), Vector2i(-1, -1), Vector2i(0, -1),
		Vector2i(-4, 0), Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0), Vector2i(4, 0),
		Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1),
		Vector2i(1, 2),
	]
	super("Vermin", CombatUnit.make_hex_health(coords))
	sprite = preload("res://assets/enemies/floor_1/vermin.png")
	actions = []
