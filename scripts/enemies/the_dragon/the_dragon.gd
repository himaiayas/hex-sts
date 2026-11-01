class_name TheDragon
extends BaseEnemy

## Floor 1 boss. Placeholder: a radius-3 hex body and the Slime's normal attack.

const RADIUS := 3


func _init() -> void:
	var coords: Array[Vector2i] = []
	for q in range(-RADIUS, RADIUS + 1):
		for r in range(maxi(-RADIUS, -q - RADIUS), mini(RADIUS, -q + RADIUS) + 1):
			coords.append(Vector2i(q, r))
	super("The Dragon", CombatUnit.make_hex_health(coords))
	actions = [
		SlimeAttack1.new(1.0),
	]
