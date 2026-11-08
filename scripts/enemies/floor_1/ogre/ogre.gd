class_name Ogre
extends BaseEnemy

## Floor 1, Normal. Cycles Wind-up -> Smash.


func _init() -> void:
	var coords: Array[Vector2i] = [
		Vector2i(-1, -3), Vector2i(0, -3), Vector2i(1, -3), Vector2i(2, -3), Vector2i(3, -3),
		Vector2i(-1, -2), Vector2i(0, -2), Vector2i(1, -2), Vector2i(2, -2), Vector2i(3, -2),
		Vector2i(-2, -1), Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1), Vector2i(2, -1),
		Vector2i(-2, 0), Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0),
		Vector2i(-3, 1), Vector2i(-2, 1), Vector2i(-1, 1), Vector2i(0, 1), Vector2i(1, 1),
		Vector2i(-3, 2), Vector2i(-2, 2), Vector2i(-1, 2), Vector2i(0, 2), Vector2i(1, 2),
	]
	super("Ogre", CombatUnit.make_hex_health(coords))
	sprite = preload("res://assets/enemies/floor_1/ogre.png")
	var smash := OgreSmash.new()
	actions = [OgreWindUp.new(smash), smash]
	p1_cycle = [0, 1]
