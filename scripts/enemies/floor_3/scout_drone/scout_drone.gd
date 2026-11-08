class_name ScoutDrone
extends BaseEnemy

## Floor 3, Normal. Laser Ping, then Scan, looped. Scan aims the next Laser Ping's first hit and
## makes it 4 tiles bigger. Hover (a power): the first HOVER hits it takes each player turn miss.

const HOVER := 2

var _ping := ScoutDroneLaserPing.new(false)
var _scanned_ping := ScoutDroneLaserPing.new(true)
var _scan := EnemyWindUp.new("Scan", "No attack. Locks on: its next Laser Ping hits 4 more tiles there.", _scanned_ping)


func _init() -> void:
	var coords: Array[Vector2i] = [
		Vector2i(-3, -3), Vector2i(-2, -3),
		Vector2i(-4, -2), Vector2i(-3, -2), Vector2i(-2, -2), Vector2i(-1, -2), Vector2i(4, -2), Vector2i(5, -2), Vector2i(6, -2), Vector2i(7, -2),
		Vector2i(-4, -1), Vector2i(-3, -1), Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1), Vector2i(2, -1), Vector2i(3, -1), Vector2i(5, -1), Vector2i(6, -1),
		Vector2i(-2, 0), Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0),
		Vector2i(-4, 1), Vector2i(-3, 1), Vector2i(-2, 1), Vector2i(-1, 1), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1), Vector2i(4, 1),
		Vector2i(-3, 2), Vector2i(-2, 2), Vector2i(-1, 2), Vector2i(0, 2), Vector2i(1, 2), Vector2i(2, 2),
		Vector2i(-3, 3), Vector2i(-2, 3), Vector2i(-1, 3), Vector2i(0, 3), Vector2i(1, 3),
	]
	super("Scout Drone", CombatUnit.make_hex_health(coords))
	sprite = preload("res://assets/enemies/floor_3/scout_drone.png")
	actions = [_ping, _scan, _scanned_ping]
	statuses.append(HoverPower.new(HOVER))


func _choose_actions() -> Array[BaseEnemyAction]:
	_turn += 1
	if _turn % 2 == 0:
		return [_scan]
	return [_ping if _turn == 1 else _scanned_ping]
