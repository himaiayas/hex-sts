extends SceneTree

## Headless check for hit reporting, random tile actions, Strength and the example cards.
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

	# Enhance gives Strength, stacks, and goes to no pile.
	_reset()
	var enhance := Enhance.new()
	_play(enhance, [], [])
	_play(Enhance.new(), [], [])
	_check(_combat.player.power_amount(StrengthPower) == 2, "two Enhance gave %d Strength" % _combat.player.power_amount(StrengthPower))
	_check(enhance not in _combat.discard_pile + _combat.hand + _combat.draw_pile, "Enhance went back to a pile")

	# Strength: each attack also damages that many tiles next to what it hit.
	var one: Array[BaseActionTile] = [DamageTile.new(Vector2i.ZERO)]
	for strength in [1, 2]:
		_reset(HEX)
		_strengthen(_combat.player, strength)
		hits = GridAction.new(Enum.TargetType.ENEMY, one).execute(_combat, _combat.enemies[0], Vector2i.ZERO)
		_check(hits.size() == 1 + strength, "%d Strength damaged %d tiles, expected %d" % [strength, hits.size(), 1 + strength])
		_check(hits.slice(1).all(func(c: Vector2i) -> bool: return c in StrengthPower.DIRS), "Strength hit a tile that isn't adjacent")

	# Per attack, not per damaged tile: a 3-tile line with 1 Strength damages 4.
	_reset(HEX)
	_strengthen(_combat.player, 1)
	hits = _line().execute(_combat, _combat.enemies[0], Vector2i(-1, 0))
	_check(hits.size() == 4, "3-tile line with 1 Strength damaged %d tiles, expected 4" % hits.size())

	# No undamaged neighbour: no extra.
	_reset(HEX)
	_strengthen(_combat.player, 1)
	for dir in StrengthPower.DIRS:
		_combat.enemies[0].health[dir].hp = DAMAGED
	hits = GridAction.new(Enum.TargetType.ENEMY, one).execute(_combat, _combat.enemies[0], Vector2i.ZERO)
	_check(hits.size() == 1, "Strength spread with no undamaged neighbour")

	# Landing on a shield or an already damaged tile still spreads.
	_reset(HEX)
	_strengthen(_combat.player, 1)
	_combat.enemies[0].health[Vector2i.ZERO].hp = SHIELDED
	hits = GridAction.new(Enum.TargetType.ENEMY, one).execute(_combat, _combat.enemies[0], Vector2i.ZERO)
	_check(hits.size() == 1 and hits[0] != Vector2i.ZERO and _alive(_combat.enemies[0]) == 6, "a blocked hit didn't spread")
	_reset(HEX)
	_strengthen(_combat.player, 1)
	_combat.enemies[0].health[Vector2i.ZERO].hp = DAMAGED
	hits = GridAction.new(Enum.TargetType.ENEMY, one).execute(_combat, _combat.enemies[0], Vector2i.ZERO)
	_check(hits.size() == 1 and _alive(_combat.enemies[0]) == 5, "a hit on a damaged tile didn't spread")

	# Shielded neighbours can take the extra (the shield absorbs it).
	_reset(HEX)
	_strengthen(_combat.player, 1)
	for dir in StrengthPower.DIRS:
		_combat.enemies[0].health[dir].hp = SHIELDED
	GridAction.new(Enum.TargetType.ENEMY, one).execute(_combat, _combat.enemies[0], Vector2i.ZERO)
	_check(_shielded(_combat.enemies[0]) == 5, "Strength didn't strip a shield when only shields were left")

	# An extra never goes on a cell the attack already landed on, even if its shield was just stripped.
	_reset(HEX)
	_strengthen(_combat.player, 1)
	for cell in HEX:
		_combat.enemies[0].health[cell].hp = DAMAGED
	_combat.enemies[0].health[Vector2i(0, 0)].hp = UNDAMAGED
	_combat.enemies[0].health[Vector2i(1, 0)].hp = SHIELDED
	var pair: Array[BaseActionTile] = [DamageTile.new(Vector2i(0, 0)), DamageTile.new(Vector2i(1, 0))]
	GridAction.new(Enum.TargetType.ENEMY, pair).execute(_combat, _combat.enemies[0], Vector2i.ZERO)
	_check(_combat.enemies[0].health[Vector2i(1, 0)].hp == UNDAMAGED, "an extra hit a cell the attack already landed on")

	# No spread on your own side's grid.
	_reset(HEX)
	_strengthen(_combat.player, 1)
	GridAction.new(Enum.TargetType.PLAYER, one).execute(_combat, _combat.player, Vector2i.ZERO)
	_check(_alive(_combat.player) == 6, "Strength spread on your own grid")

	# Only the acting unit's Strength counts: an enemy's on its turn, not the player's.
	_reset(HEX)
	_strengthen(_combat.player, 1)
	_combat.player.in_turn = false
	_strengthen(_combat.enemies[0], 1)
	_combat.enemies[0].in_turn = true
	GridAction.new(Enum.TargetType.PLAYER, one).execute(_combat, _combat.player, Vector2i.ZERO)
	_check(_alive(_combat.player) == 5, "enemy Strength didn't spread on its turn")
	_combat.enemies[0].statuses.clear()
	GridAction.new(Enum.TargetType.ENEMY, one).execute(_combat, _combat.enemies[0], Vector2i.ZERO)
	_check(_alive(_combat.enemies[0]) == 6, "player Strength spread on the enemy's turn")

	# Strength counts for Thrust's condition, and spreads from random hits too.
	_reset()
	_strengthen(_combat.player, 1)
	_play(Thrust.new(), [_combat.enemies[0]], [Vector2i(2, 0)])
	_check(_shielded(_combat.player) == 0, "Thrust didn't count the Strength hit")
	_reset(HEX)
	_strengthen(_combat.player, 1)
	_play(RapidFire.new(), [_combat.enemies[0]], [Vector2i.ZERO])
	_check(_alive(_combat.enemies[0]) == 3, "Rapid Fire with 1 Strength left %d tiles, expected 3" % _alive(_combat.enemies[0]))
	_reset(LINE, 2)
	_strengthen(_combat.player, 1)
	_play(ArrowRain.new(), [], [])
	_check(_alive(_combat.enemies[0]) + _alive(_combat.enemies[1]) == 0, "Arrow Rain didn't spread")

	# A grid action can't be aimed at a damaged tile; shielded or undamaged is fine.
	_reset(HEX)
	_combat.enemies[0].health[Vector2i.ZERO].hp = DAMAGED
	_combat.enemies[0].health[Vector2i(1, 0)].hp = SHIELDED
	_check(not _try(Strike.new(), [_combat.enemies[0]], [Vector2i.ZERO]), "played Strike on a damaged anchor")
	_check(_combat.energy == 1 and _combat.hand.size() == 1, "a refused play still cost energy or left the hand")
	_check(_try(Strike.new(), [_combat.enemies[0]], [Vector2i(1, 0)]), "couldn't play Strike on a shielded anchor")
	_reset(HEX)
	_check(_try(Strike.new(), [_combat.enemies[0]], [Vector2i(0, 1)]), "couldn't play Strike on an undamaged anchor")
	_reset(HEX)
	_combat.enemies[0].health[Vector2i(1, 0)].hp = DAMAGED
	_check(not _try(WomboCombo.new(), [_combat.enemies[0], _combat.enemies[0]], [Vector2i.ZERO, Vector2i(1, 0)]), "played Wombo Combo with a damaged second anchor")
	_reset(HEX)
	_combat.enemies[0].health[Vector2i.ZERO].hp = DAMAGED
	_check(_try(RapidFire.new(), [_combat.enemies[0]], [Vector2i.ZERO]), "Rapid Fire couldn't pick a grid by a damaged tile")

	_run.free()
	print("action_check: %s" % ("OK" if _failures == 0 else "%d failure(s)" % _failures))
	quit(_failures)


## Fresh run and fight against count enemies, each with tiles at coords.
func _reset(coords := LINE, count := 1) -> void:
	_run.start_new_run()
	_combat = CombatState.new(_run)
	for i in count:
		_combat.enemies.append(CombatUnit.new("Enemy %d" % i, CombatUnit.make_hex_health(coords)))


## Gives unit amount Strength and makes it the acting unit.
func _strengthen(unit: CombatUnit, amount: int) -> void:
	unit.add_power(StrengthPower.new(amount))
	unit.in_turn = true


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


## Puts card in hand with exactly its cost in energy and tries to play it.
func _try(card: BaseCard, units: Array[CombatUnit], cells: Array[Vector2i]) -> bool:
	_combat.hand.clear()
	_combat.hand.append(card)
	_combat.energy = card.cost
	var rotations: Array[int] = []
	for i in cells.size():
		rotations.append(0)
	return _combat.play_card(card, units, cells, rotations)


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
