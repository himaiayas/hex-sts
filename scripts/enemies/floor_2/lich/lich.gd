class_name Lich
extends BaseEnemy

## Floor 2, Elite. Cycles Summon Lil Ghost -> Soul Drain -> Bone Storm; while its ghost is alive,
## Soul Drain replaces the Summon. Phylactery: a Mimic fights beside it, and while the Mimic
## stands it has Regen REGEN. When the Lich dies, the Mimic and its ghosts die with it.

const MAX_GHOSTS := 1
const REGEN := 5

var mimic: Mimic
var summons: Array[LilGhost] = []

var _soul_drain: EnemyHit


func _init() -> void:
	var coords: Array[Vector2i] = [
		Vector2i(3, -8),
		Vector2i(2, -7), Vector2i(3, -7),
		Vector2i(1, -6), Vector2i(2, -6), Vector2i(3, -6),
		Vector2i(1, -5), Vector2i(2, -5), Vector2i(7, -5),
		Vector2i(0, -4), Vector2i(1, -4), Vector2i(2, -4), Vector2i(6, -4), Vector2i(7, -4),
		Vector2i(-1, -3), Vector2i(0, -3), Vector2i(1, -3), Vector2i(2, -3), Vector2i(6, -3),
		Vector2i(-2, -2), Vector2i(-1, -2), Vector2i(0, -2), Vector2i(1, -2), Vector2i(2, -2), Vector2i(5, -2), Vector2i(6, -2),
		Vector2i(-2, -1), Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1), Vector2i(2, -1), Vector2i(3, -1), Vector2i(4, -1), Vector2i(5, -1),
		Vector2i(-3, 0), Vector2i(-2, 0), Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0), Vector2i(4, 0), Vector2i(5, 0),
		Vector2i(-3, 1), Vector2i(-2, 1), Vector2i(-1, 1), Vector2i(0, 1), Vector2i(4, 1),
		Vector2i(-4, 2), Vector2i(-3, 2), Vector2i(-2, 2), Vector2i(-1, 2), Vector2i(0, 2), Vector2i(3, 2), Vector2i(4, 2),
		Vector2i(-6, 3), Vector2i(-5, 3), Vector2i(-4, 3), Vector2i(-3, 3), Vector2i(-2, 3), Vector2i(-1, 3), Vector2i(0, 3), Vector2i(1, 3), Vector2i(3, 3),
		Vector2i(-6, 4), Vector2i(-5, 4), Vector2i(-4, 4), Vector2i(-3, 4), Vector2i(-2, 4), Vector2i(-1, 4), Vector2i(0, 4), Vector2i(2, 4), Vector2i(3, 4),
		Vector2i(-6, 5), Vector2i(-5, 5), Vector2i(-4, 5), Vector2i(-3, 5), Vector2i(-2, 5), Vector2i(-1, 5), Vector2i(2, 5),
		Vector2i(1, 6), Vector2i(2, 6),
	]
	super("Lich", CombatUnit.make_hex_health(coords))
	sprite = preload("res://assets/enemies/floor_2/lich.png")
	var fracture: Array[BaseActionTile] = [ApplyEffectTile.new(Vector2i.ZERO, FractureTileEffect.new())]
	_soul_drain = EnemyHit.new("Soul Drain", "Fracture 4 random tiles.", fracture, 4)
	_soul_drain.action_type = Enum.BaseEnemyActionEnum.DEBUFF
	# Two rows of 4.
	var bones: Array[BaseActionTile] = []
	for r in 2:
		for q in 4:
			bones.append(DamageTile.new(Vector2i(q - r, r)))
	actions = [
		LichSummon.new(),
		_soul_drain,
		EnemyHit.new("Bone Storm", "Hit 8 tiles 3 times.", bones, 3),
	]
	p1_cycle = [0, 1, 2]
	statuses.append(RegenPower.new(REGEN))
	mimic = Mimic.new(self)
	companions = [mimic]
	shrinks = false


func _choose_actions() -> Array[BaseEnemyAction]:
	var chosen := super()
	if chosen[0] is LichSummon and summons.filter(func(g: LilGhost) -> bool: return not g.is_dead()).size() >= MAX_GHOSTS:
		return [_soul_drain]
	return chosen


## When it dies, its Mimic and ghosts go with it: gone, not hit, so no animation and no triggers.
func fire_at(trigger: Enum.Trigger, combat: CombatState, cell: Vector2i) -> void:
	super(trigger, combat, cell)
	if trigger != Enum.Trigger.ON_HIT or not is_dead():
		return
	var linked: Array[CombatUnit] = [mimic]
	linked.append_array(summons)
	for unit in linked:
		for tile in unit.health.values():
			tile.hp = Enum.HealthTileEnum.DAMAGED
