class_name Dragon
extends BaseEnemy

## Floor 1, Boss. P1 cycles Claw -> Tail Sweep -> Fire Breath. Below half its tiles (P2)
## it cycles Claw -> Inferno -> Tail Sweep -> Inferno, starting over at Claw.


func _init() -> void:
	var coords: Array[Vector2i] = [
		Vector2i(2, -6), Vector2i(3, -6), Vector2i(4, -6),
		Vector2i(1, -5), Vector2i(2, -5), Vector2i(3, -5), Vector2i(4, -5),
		Vector2i(2, -4),
		Vector2i(-6, -3), Vector2i(-5, -3), Vector2i(-4, -3), Vector2i(-3, -3), Vector2i(1, -3), Vector2i(2, -3), Vector2i(6, -3), Vector2i(7, -3), Vector2i(8, -3), Vector2i(9, -3),
		Vector2i(-8, -2), Vector2i(-7, -2), Vector2i(-6, -2), Vector2i(-5, -2), Vector2i(-4, -2), Vector2i(-3, -2), Vector2i(-2, -2), Vector2i(0, -2), Vector2i(1, -2), Vector2i(2, -2), Vector2i(4, -2), Vector2i(5, -2), Vector2i(6, -2), Vector2i(7, -2), Vector2i(8, -2), Vector2i(9, -2), Vector2i(10, -2),
		Vector2i(-8, -1), Vector2i(-7, -1), Vector2i(-6, -1), Vector2i(-5, -1), Vector2i(-4, -1), Vector2i(-3, -1), Vector2i(-2, -1), Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1), Vector2i(2, -1), Vector2i(3, -1), Vector2i(4, -1), Vector2i(5, -1), Vector2i(6, -1), Vector2i(7, -1), Vector2i(8, -1), Vector2i(9, -1),
		Vector2i(-8, 0), Vector2i(-7, 0), Vector2i(-6, 0), Vector2i(-5, 0), Vector2i(-4, 0), Vector2i(-2, 0), Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(4, 0), Vector2i(5, 0), Vector2i(6, 0), Vector2i(7, 0), Vector2i(8, 0),
		Vector2i(-2, 1), Vector2i(-1, 1), Vector2i(0, 1), Vector2i(1, 1),
		Vector2i(-3, 2), Vector2i(-2, 2), Vector2i(-1, 2), Vector2i(0, 2), Vector2i(1, 2),
		Vector2i(-3, 3), Vector2i(-2, 3), Vector2i(-1, 3), Vector2i(0, 3),
		Vector2i(-2, 4),
		Vector2i(-3, 5), Vector2i(-2, 5),
		Vector2i(-3, 6),
		Vector2i(-4, 7), Vector2i(-3, 7),
		Vector2i(-4, 8),
		Vector2i(-5, 9), Vector2i(-4, 9),
	]
	super("The Dragon", CombatUnit.make_hex_health(coords))
	idle_frames = [
		preload("res://assets/enemies/floor_1/dragon_idle1.png"),
		preload("res://assets/enemies/floor_1/dragon_idle2.png"),
		preload("res://assets/enemies/floor_1/dragon_idle3.png"),
		preload("res://assets/enemies/floor_1/dragon_idle2.png"),
	]
	# Smaller than the most that fits, so its enlarged grid gets the width.
	image_size = Vector2(600, 600)
	grid_scale = 1.5  # big shapes: a larger box keeps the hexes readable
	hit_vfx_area = Rect2(349, 244, 356, 582)  # x 349-705, y 244-826: between your grid and the Dragon
	actions = [
		DragonClaw.new(),
		DragonTailSweep.new(),
		DragonFireBreath.new(),
		DragonFireBreath.new(true),
	]
	p1_cycle = [0, 1, 2]
	p2_cycle = [0, 3, 1, 3]

