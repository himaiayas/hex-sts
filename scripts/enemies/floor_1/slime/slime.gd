class_name Slime
extends BaseEnemy

## Floor 1, Normal. Cycles Splat -> Goo. Split: once SPLIT_AT or fewer tiles are left, its intent
## turns into Split at once, and on its turn it splits into 2 Mini Slimes. Destroyed outright, it doesn't.

const SPLIT_AT := 6

var _split := SlimeSplit.new()


func _init() -> void:
	var coords: Array[Vector2i] = [
		Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1), Vector2i(2, -1),
		Vector2i(-2, 0), Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0),
		Vector2i(-2, 1), Vector2i(-1, 1), Vector2i(0, 1), Vector2i(1, 1),
	]
	super("Slime", CombatUnit.make_hex_health(coords))
	sprite = preload("res://assets/enemies/floor_1/slime.png")
	var splat: Array[BaseActionTile] = [
		DamageTile.new(Vector2i(0, 0)),
		DamageTile.new(Vector2i(1, 0)),
		DamageTile.new(Vector2i(-1, 1)),
		DamageTile.new(Vector2i(0, 1)),
	]
	actions = [
		EnemyHit.new("Splat", "Hit 4 tiles in a blob.", splat),
		EnemyShieldSelf.new("Goo", 4, "Shield 4 random tiles of its own."),
	]
	p1_cycle = [0, 1]


func _choose_actions() -> Array[BaseEnemyAction]:
	return [_split] if _splitting() else super()


func fire_at(trigger: Enum.Trigger, combat: CombatState, cell: Vector2i) -> void:
	super(trigger, combat, cell)
	if _splitting() and _split not in intent_actions:
		intent_actions = [_split]


func _splitting() -> bool:
	var left := health.values().filter(func(t: HealthTile) -> bool: return t.hp > Enum.HealthTileEnum.DAMAGED).size()
	return left > 0 and left <= SPLIT_AT
