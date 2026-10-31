extends SceneTree

## Headless check for hit reporting, random tile actions and the #9 example cards.
## Exit code = number of failures.
## godot --headless --path . -s res://scripts/actions/action_check.gd

const DAMAGED := Enum.HealthTileEnum.DAMAGED
const UNDAMAGED := Enum.HealthTileEnum.UNDAMAGED
const SHIELDED := Enum.HealthTileEnum.SHIELDED
const LINE: Array[Vector2i] = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0)]
const HEX: Array[Vector2i] = [
	Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 1),
	Vector2i(-1, 0), Vector2i(0, -1), Vector2i(1, -1),
]

var _failures := 0
var _run: Node
var _combat: CombatState


func _initialize() -> void:
	_run = load("res://scripts/game/run_state.gd").new()
	_run.start_new_run()

	# A shield block or an already damaged tile isn't a hit.
	_reset()
	var enemy := _combat.enemies[0]
	enemy.health[LINE[1]].hp = SHIELDED
	enemy.health[LINE[2]].hp = DAMAGED
	var hits := _line().execute(_combat, enemy, LINE[0])
	_check(hits == ([LINE[0]] as Array[Vector2i]), "line hits were %s, expected only %s" % [hits, LINE[0]])
	_check(enemy.health[LINE[1]].hp == UNDAMAGED, "shield didn't absorb the hit")

	# Random damage among all enemies: distinct, open tiles only, never on a dead enemy.
	for i in 20:
		_reset(HEX, 3)
		var dead := _combat.enemies[1]
		for cell in dead.health:
			dead.health[cell].hp = DAMAGED
		_combat.enemies[0].health[LINE[0]].hp = DAMAGED
		var before := _hp_snapshot()
		hits = RandomTileAction.new(Enum.TargetType.ENEMY, DamageTile.new(Vector2i.ZERO), 5).execute(_combat, null, Vector2i.ZERO)
		var changed := _changed_since(before)
		_check(changed.size() == 5, "random damage changed %d tiles, expected 5" % changed.size())
		_check(changed.all(func(c: Array) -> bool: return c[0] != dead and before[c[0]][c[1]] != DAMAGED), "random damage hit a dead enemy or a damaged tile")

	# Fewer open tiles than hits: every open tile is hit once, nothing breaks.
	_reset()
	hits = RandomTileAction.new(Enum.TargetType.ENEMY, DamageTile.new(Vector2i.ZERO), 5).execute(_combat, null, Vector2i.ZERO)
	_check(hits.size() == 3 and _combat.enemies[0].is_dead(), "random damage on a 3-tile enemy hit %d" % hits.size())

	# Random shield on your own grid skips damaged and already shielded tiles.
	_reset()
	var cells := _combat.player.health.keys()
	for i in cells.size() - 1:
		_combat.player.health[cells[i]].hp = DAMAGED if i % 2 == 0 else SHIELDED
	hits = RandomTileAction.new(Enum.TargetType.PLAYER, ShieldTile.new(Vector2i.ZERO)).execute(_combat, null, Vector2i.ZERO)
	_check(hits == ([cells[-1]] as Array[Vector2i]), "random shield went on %s, expected %s" % [hits, cells[-1]])

	# Random tiles on a chosen grid stay on that grid.
	_reset()
	var other := CombatUnit.new("Other", CombatUnit.make_hex_health(LINE))
	_combat.enemies.append(other)
	hits = RandomGridAction.new(Enum.TargetType.ENEMY, DamageTile.new(Vector2i.ZERO), 2).execute(_combat, _combat.enemies[0], Vector2i(9, 9))
	_check(hits.size() == 2 and _alive(_combat.enemies[0]) == 1 and _alive(other) == 3, "random grid action left the chosen grid")

	# Thrust shields one of your tiles only when it damages fewer than 2 tiles.
	_reset()
	_play(Thrust.new(), [_combat.enemies[0]], [LINE[0]])
	_check(_shielded(_combat.player) == 0, "Thrust shielded after 3 hits")
	_reset()
	_play(Thrust.new(), [_combat.enemies[0]], [Vector2i(2, 0)])  # only (2,0) is on the grid
	_check(_shielded(_combat.player) == 1, "Thrust didn't shield after 1 hit")

	# Divine Mercy: costs 1, gives 2 (not capped by max_energy), draws 1.
	_reset()
	_combat.energy = 3
	var hand_size := _combat.hand.size()
	_play(DivineMercy.new(), [], [])
	_check(_combat.energy == 4, "energy after Divine Mercy was %d, expected 4" % _combat.energy)
	_check(_combat.hand.size() == hand_size + 1, "Divine Mercy didn't draw 1")

	# Rapid Fire hits 3 tiles of the clicked enemy; Arrow Rain hits 5 across all enemies.
	_reset(HEX)
	_play(RapidFire.new(), [_combat.enemies[0]], [Vector2i.ZERO])
	_check(_alive(_combat.enemies[0]) == 4, "Rapid Fire left %d tiles, expected 4" % _alive(_combat.enemies[0]))
	_reset(LINE, 2)
	_play(ArrowRain.new(), [], [])
	_check(_alive(_combat.enemies[0]) + _alive(_combat.enemies[1]) == 1, "Arrow Rain didn't hit 5 tiles")

	_run.free()
	print("action_check: %s" % ("OK" if _failures == 0 else "%d failure(s)" % _failures))
	quit(_failures)


## Fresh run and fight against count enemies, each with tiles at coords.
func _reset(coords := LINE, count := 1) -> void:
	_run.start_new_run()
	_combat = CombatState.new(_run)
	for i in count:
		_combat.enemies.append(CombatUnit.new("Enemy %d" % i, CombatUnit.make_hex_health(coords)))


func _line() -> GridAction:
	var tiles: Array[BaseActionTile] = [DamageTile.new(Vector2i(0, 0)), DamageTile.new(Vector2i(1, 0)), DamageTile.new(Vector2i(2, 0))]
	return GridAction.new(Enum.TargetType.ENEMY, tiles)


func _play(card: BaseCard, units: Array[CombatUnit], cells: Array[Vector2i]) -> void:
	_combat.energy = maxi(_combat.energy, card.cost)
	_combat.hand.append(card)
	var rotations: Array[int] = []
	for i in cells.size():
		rotations.append(0)
	_check(_combat.play_card(card, units, cells, rotations), "%s couldn't be played" % card.card_name)


func _hp_snapshot() -> Dictionary:
	var snapshot := {}
	for unit in _combat.enemies:
		snapshot[unit] = {}
		for cell in unit.health:
			snapshot[unit][cell] = unit.health[cell].hp
	return snapshot


## [unit, cell] of every enemy tile whose hp changed since the snapshot.
func _changed_since(before: Dictionary) -> Array:
	var changed := []
	for unit in _combat.enemies:
		for cell in unit.health:
			if unit.health[cell].hp != before[unit][cell]:
				changed.append([unit, cell])
	return changed


func _alive(unit: CombatUnit) -> int:
	return unit.health.values().filter(func(t: HealthTile) -> bool: return t.hp != DAMAGED).size()


func _shielded(unit: CombatUnit) -> int:
	return unit.health.values().filter(func(t: HealthTile) -> bool: return t.hp == SHIELDED).size()


func _check(ok: bool, msg: String) -> void:
	if not ok:
		_failures += 1
		printerr("FAIL: ", msg)
