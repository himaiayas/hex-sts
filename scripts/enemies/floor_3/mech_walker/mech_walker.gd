class_name MechWalker
extends BaseEnemy

## Floor 3, Elite. Cycles Missile Salvo -> Stomp -> Shield Up. Armor Plating: starts with ARMOR
## Shields and tops them back up every ARMOR_EVERY turns, before its move.

const ARMOR := 20
const ARMOR_EVERY := 3

var _armor := EnemyField.new("Armor Plating", ARMOR)
var _turns := 0  # turns planned, for Armor Plating


func _init() -> void:
	var coords: Array[Vector2i] = [
		Vector2i(2, -7), Vector2i(3, -7), Vector2i(4, -7), Vector2i(5, -7),
		Vector2i(1, -6), Vector2i(2, -6), Vector2i(3, -6), Vector2i(4, -6), Vector2i(5, -6),
		Vector2i(0, -5), Vector2i(1, -5), Vector2i(2, -5), Vector2i(3, -5), Vector2i(4, -5), Vector2i(5, -5),
		Vector2i(-1, -4), Vector2i(0, -4), Vector2i(1, -4), Vector2i(2, -4), Vector2i(3, -4), Vector2i(4, -4), Vector2i(5, -4),
		Vector2i(-1, -3), Vector2i(0, -3), Vector2i(1, -3), Vector2i(2, -3), Vector2i(3, -3), Vector2i(4, -3),
		Vector2i(-2, -2), Vector2i(-1, -2), Vector2i(0, -2), Vector2i(1, -2), Vector2i(2, -2), Vector2i(3, -2), Vector2i(4, -2),
		Vector2i(-3, -1), Vector2i(-2, -1), Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1), Vector2i(2, -1), Vector2i(3, -1), Vector2i(4, -1),
		Vector2i(-3, 0), Vector2i(-2, 0), Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0),
		Vector2i(-4, 1), Vector2i(-3, 1), Vector2i(-2, 1), Vector2i(-1, 1), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1),
		Vector2i(-5, 2), Vector2i(-4, 2), Vector2i(-3, 2), Vector2i(1, 2), Vector2i(2, 2), Vector2i(3, 2),
		Vector2i(-5, 3), Vector2i(-4, 3), Vector2i(1, 3), Vector2i(2, 3),
		Vector2i(-6, 4), Vector2i(-5, 4), Vector2i(-4, 4), Vector2i(0, 4), Vector2i(1, 4), Vector2i(2, 4),
		Vector2i(-6, 5), Vector2i(-5, 5), Vector2i(0, 5), Vector2i(1, 5),
		Vector2i(-6, 6), Vector2i(0, 6),
		Vector2i(-9, 7), Vector2i(-8, 7), Vector2i(-7, 7), Vector2i(-6, 7), Vector2i(-5, 7), Vector2i(-2, 7), Vector2i(-1, 7), Vector2i(0, 7), Vector2i(1, 7), Vector2i(2, 7),
	]
	super("Mech Walker", CombatUnit.make_hex_health(coords))
	sprite = preload("res://assets/enemies/floor_3/mech_walker.png")
	var missile: Array[BaseActionTile] = [
		DamageTile.new(Vector2i(0, 0)),
		DamageTile.new(Vector2i(1, 0)),
		DamageTile.new(Vector2i(0, 1)),
	]
	var foot: Array[BaseActionTile] = []
	for r in 2:
		for q in 3:
			foot.append(DamageTile.new(Vector2i(q - floori(r / 2.0), r)))  # rows line up, not slant
	actions = [
		EnemyHit.new("Missile Salvo", "Hit 3 tiles 4 times.", missile, 4),
		EnemyHit.new("Stomp", "Hit 6 tiles in a 2x3 block.", foot),
		EnemyShieldSelf.new("Shield Up", 12, "Shield 12 random tiles of its own."),
		_armor,
	]
	p1_cycle = [0, 1, 2]
	EnemyField.shield_start(self, ARMOR)


func _choose_actions() -> Array[BaseEnemyAction]:
	_turns += 1
	var rows: Array[BaseEnemyAction] = []
	if _turns % ARMOR_EVERY == 0 and EnemyField.shields(self) < ARMOR:
		rows.append(_armor)
	rows.append(_choose_action())
	return rows
