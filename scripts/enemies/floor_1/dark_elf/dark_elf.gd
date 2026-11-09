class_name DarkElf
extends BaseEnemy

## Floor 1, Normal. Cycles Poison Dart -> Shadow Step.


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
	# A line of 4, with Poison on the tile past its tip.
	var dart: Array[BaseActionTile] = []
	for q in 3:
		dart.append(DamageTile.new(Vector2i(q, 0)))
	dart.append(ApplyEffectTile.new(Vector2i(3, 0), PoisonTileEffect.new()))
	var poison_dart := EnemyHit.new("Poison Dart", "Hit 3 tiles in a line and Poison the tile past its tip.", dart)
	# The arrow alone, without the image's empty margin.
	var arrow := AtlasTexture.new()
	arrow.atlas = preload("res://assets/enemies/floor_1/dark_elf_arrow.png")
	arrow.region = Rect2(312, 444, 376, 38)
	poison_dart.projectile_vfx = arrow
	actions = [poison_dart, DarkElfShadowStep.new()]
	p1_cycle = [0, 1]
