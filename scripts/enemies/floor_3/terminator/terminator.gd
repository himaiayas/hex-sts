class_name Terminator
extends BaseEnemy

## Floor 3, Elite. Cycles Rally -> Rifle Barrage -> Execute. Execute is only planned while the player
## has half their tiles or fewer left; otherwise that turn is another Rifle Barrage.

var _barrage: EnemyHit
var _execute: EnemyHit


func _init() -> void:
	var coords: Array[Vector2i] = [
		Vector2i(3, -8), Vector2i(4, -8), Vector2i(5, -8),
		Vector2i(3, -7), Vector2i(4, -7),
		Vector2i(2, -6), Vector2i(3, -6), Vector2i(4, -6),
		Vector2i(-2, -5), Vector2i(-1, -5), Vector2i(0, -5), Vector2i(1, -5), Vector2i(2, -5), Vector2i(3, -5), Vector2i(4, -5), Vector2i(5, -5), Vector2i(6, -5), Vector2i(7, -5),
		Vector2i(-3, -4), Vector2i(-2, -4), Vector2i(0, -4), Vector2i(1, -4), Vector2i(2, -4), Vector2i(3, -4), Vector2i(4, -4), Vector2i(6, -4), Vector2i(7, -4),
		Vector2i(-3, -3), Vector2i(-2, -3), Vector2i(-1, -3), Vector2i(0, -3), Vector2i(1, -3), Vector2i(2, -3), Vector2i(3, -3), Vector2i(4, -3), Vector2i(5, -3), Vector2i(6, -3),
		Vector2i(-4, -2), Vector2i(-3, -2), Vector2i(-1, -2), Vector2i(0, -2), Vector2i(1, -2), Vector2i(2, -2), Vector2i(3, -2), Vector2i(5, -2), Vector2i(6, -2),
		Vector2i(-4, -1), Vector2i(-3, -1), Vector2i(-2, -1), Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1), Vector2i(2, -1), Vector2i(3, -1), Vector2i(4, -1), Vector2i(5, -1),
		Vector2i(-5, 0), Vector2i(-4, 0), Vector2i(-2, 0), Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0), Vector2i(4, 0), Vector2i(5, 0), Vector2i(6, 0),
		Vector2i(-2, 1), Vector2i(-1, 1), Vector2i(0, 1), Vector2i(1, 1),
		Vector2i(-3, 2), Vector2i(-2, 2), Vector2i(-1, 2), Vector2i(0, 2), Vector2i(1, 2),
		Vector2i(-3, 3), Vector2i(-2, 3), Vector2i(-1, 3), Vector2i(0, 3),
		Vector2i(-4, 4), Vector2i(-3, 4), Vector2i(-1, 4), Vector2i(0, 4),
		Vector2i(-4, 5), Vector2i(-3, 5), Vector2i(-2, 5), Vector2i(-1, 5),
		Vector2i(-5, 6), Vector2i(-4, 6), Vector2i(-2, 6), Vector2i(-1, 6),
		Vector2i(-5, 7), Vector2i(-4, 7), Vector2i(-3, 7), Vector2i(-2, 7),
		Vector2i(-6, 8), Vector2i(-5, 8), Vector2i(-3, 8), Vector2i(-2, 8),
	]
	super("Terminator", CombatUnit.make_hex_health(coords))
	sprite = preload("res://assets/enemies/floor_3/terminator.png")
	var burst: Array[BaseActionTile] = []
	for r in 2:
		for q in 3:
			burst.append(DamageTile.new(Vector2i(q - floori(r / 2.0), r)))  # rows line up, not slant
	var block: Array[BaseActionTile] = []
	for r in 4:
		for q in 5:
			block.append(DamageTile.new(Vector2i(q - floori(r / 2.0), r)))
	_barrage = EnemyHit.new("Rifle Barrage", "Hit 6 tiles 3 times.", burst, 3)
	_execute = EnemyHit.new("Execute", "Hit 20 tiles in a 4x5 block. Only when you have half your tiles or fewer.", block)
	actions = [TerminatorRally.new(), _barrage, _execute]
	p1_cycle = [0, 1, 2]


func plan(combat: CombatState) -> void:
	super(combat)
	var player := combat.player
	var undamaged := player.health.values().filter(func(t: HealthTile) -> bool: return t.hp > Enum.HealthTileEnum.DAMAGED).size()
	if intent_actions == [_execute] and undamaged * 2 > player.health.size():
		intent_actions = [_barrage]
		_barrage.plan(combat, self)
