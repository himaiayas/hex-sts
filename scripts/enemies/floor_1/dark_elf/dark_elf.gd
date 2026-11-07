class_name DarkElf
extends BaseEnemy

## Floor 1, Normal.


func _init() -> void:
	var coords: Array[Vector2i] = [
		Vector2i(2, -6),
		Vector2i(1, -5), Vector2i(2, -5),
		Vector2i(1, -4), Vector2i(2, -4), Vector2i(3, -4),
		Vector2i(1, -3), Vector2i(3, -3), Vector2i(4, -3),
		Vector2i(0, -2), Vector2i(1, -2), Vector2i(3, -2), Vector2i(4, -2),
		Vector2i(0, -1), Vector2i(2, -1), Vector2i(3, -1), Vector2i(4, -1),
		Vector2i(-1, 0), Vector2i(0, 0), Vector2i(2, 0), Vector2i(3, 0),
		Vector2i(-2, 1), Vector2i(-1, 1), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1),
		Vector2i(-2, 2), Vector2i(-1, 2), Vector2i(0, 2), Vector2i(1, 2),
		Vector2i(-2, 3), Vector2i(-1, 3), Vector2i(0, 3),
		Vector2i(-3, 4), Vector2i(-2, 4),
		Vector2i(-3, 5),
	]
	super("Dark Elf", CombatUnit.make_hex_health(coords))
	sprite = preload("res://assets/enemies/floor_1/dark_elf.png")
	actions = []
