class_name MiniSlime
extends BaseEnemy

## Floor 1, from a Slime's Split. Tiny Splat every turn. Doesn't split again.


func _init() -> void:
	var coords: Array[Vector2i] = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1)]
	super("Mini Slime", CombatUnit.make_hex_health(coords))
	sprite = preload("res://assets/enemies/floor_1/slime.png")
	image_size = Vector2(150, 150)  # half the usual
	var splat: Array[BaseActionTile] = [DamageTile.new(Vector2i(0, 0)), DamageTile.new(Vector2i(1, 0))]
	actions = [EnemyHit.new("Tiny Splat", "Hit 2 tiles.", splat)]
