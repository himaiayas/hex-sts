class_name Slime
extends BaseEnemy


## Hexagon of this radius: 3r(r+1)+1 tiles (8 -> 217).
const RADIUS := 8


func _init() -> void:
	var coords: Array[Vector2i] = []
	for q in range(-RADIUS, RADIUS + 1):
		for r in range(maxi(-RADIUS, -q - RADIUS), mini(RADIUS, -q + RADIUS) + 1):
			coords.append(Vector2i(q, r))
	# Sheet shape (12 tiles), kept off while testing with the big hexagon.
	#coords = [
	#	Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1), Vector2i(2, -1),
	#	Vector2i(-2, 0), Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0),
	#	Vector2i(-2, 1), Vector2i(-1, 1), Vector2i(0, 1), Vector2i(1, 1),
	#]
	super("Slime", CombatUnit.make_hex_health(coords))
	sprite = preload("res://assets/enemies/slime.png")
	actions = [
		SlimeAttack1.new(0.5),
		SlimeHarden.new(0.25),
		SlimeGuardedBash.new(0.25),
	]
