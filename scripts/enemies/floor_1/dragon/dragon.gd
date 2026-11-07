class_name Dragon
extends BaseEnemy

## Floor 1, Boss. P1 cycles Claw -> Tail Sweep -> Fire Breath. Below half its tiles (P2)
## it cycles Claw -> Inferno -> Tail Sweep -> Inferno, starting over at Claw.

const P1_CYCLE: Array[int] = [0, 1, 2]  # indexes into actions
const P2_CYCLE: Array[int] = [0, 3, 1, 3]

var in_p2 := false
var _turn := 0  # moves chosen so far in this phase


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
	super("Dragon", CombatUnit.make_hex_health(coords))
	idle_frames = [
		preload("res://assets/enemies/floor_1/dragon_idle1.png"),
		preload("res://assets/enemies/floor_1/dragon_idle2.png"),
	]
	actions = [
		DragonClaw.new(),
		DragonTailSweep.new(),
		DragonFireBreath.new(),
		DragonFireBreath.new(true),
	]


func _choose_action() -> BaseEnemyAction:
	var undamaged := health.values().filter(func(t: HealthTile) -> bool: return t.hp > Enum.HealthTileEnum.DAMAGED).size()
	if not in_p2 and undamaged * 2 < health.size():
		in_p2 = true
		_turn = 0
	var cycle := P2_CYCLE if in_p2 else P1_CYCLE
	var action := actions[cycle[_turn % cycle.size()]]
	_turn += 1
	return action
