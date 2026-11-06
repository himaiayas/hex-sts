extends SceneTree

## Headless check for hit reporting, random tile actions, Strength, the example cards, the exhaust, retain
## and discard piles, Heal, Sacrifice, Retaliate, Pierce, whole-line patterns and Jab's return to the draw pile.
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
	var hits := await _line().execute(_combat, enemy, LINE[0])
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
		hits = await RandomTileAction.new(Enum.TargetType.ENEMY, DamageTile.new(Vector2i.ZERO), 5).execute(_combat, null, Vector2i.ZERO)
		var changed := _changed_since(before)
		_check(changed.size() == 5, "random damage changed %d tiles, expected 5" % changed.size())
		_check(changed.all(func(c: Array) -> bool: return c[0] != dead and before[c[0]][c[1]] != DAMAGED), "random damage hit a dead enemy or a damaged tile")

	# Fewer open tiles than hits: every open tile is hit once, nothing breaks.
	_reset()
	hits = await RandomTileAction.new(Enum.TargetType.ENEMY, DamageTile.new(Vector2i.ZERO), 5).execute(_combat, null, Vector2i.ZERO)
	_check(hits.size() == 3 and _combat.enemies[0].is_dead(), "random damage on a 3-tile enemy hit %d" % hits.size())

	# Random shield on your own grid skips damaged and already shielded tiles.
	_reset()
	var cells := _combat.player.health.keys()
	for i in cells.size() - 1:
		_combat.player.health[cells[i]].hp = DAMAGED if i % 2 == 0 else SHIELDED
	hits = await RandomTileAction.new(Enum.TargetType.PLAYER, ShieldTile.new(Vector2i.ZERO)).execute(_combat, null, Vector2i.ZERO)
	_check(hits == ([cells[-1]] as Array[Vector2i]), "random shield went on %s, expected %s" % [hits, cells[-1]])

	# Random tiles on a chosen grid stay on that grid.
	_reset()
	var other := CombatUnit.new("Other", CombatUnit.make_hex_health(LINE))
	_combat.enemies.append(other)
	hits = await RandomGridAction.new(Enum.TargetType.ENEMY, DamageTile.new(Vector2i.ZERO), 2).execute(_combat, _combat.enemies[0], Vector2i(9, 9))
	_check(hits.size() == 2 and _alive(_combat.enemies[0]) == 1 and _alive(other) == 3, "random grid action left the chosen grid")

	# Thrust shields one of your tiles only when it damages fewer than 2 tiles.
	_reset()
	await _play(Thrust.new(), [_combat.enemies[0]], [LINE[0]])
	_check(_shielded(_combat.player) == 0, "Thrust shielded after 3 hits")
	_reset()
	await _play(Thrust.new(), [_combat.enemies[0]], [Vector2i(2, 0)])  # only (2,0) is on the grid
	_check(_shielded(_combat.player) == 1, "Thrust didn't shield after 1 hit")

	# Divine Mercy: costs 1, gives 2 (not capped by max_energy), draws 1.
	_reset()
	_combat.energy = 3
	var hand_size := _combat.hand.size()
	await _play(DivineMercy.new(), [], [])
	_check(_combat.energy == 4, "energy after Divine Mercy was %d, expected 4" % _combat.energy)
	_check(_combat.hand.size() == hand_size + 1, "Divine Mercy didn't draw 1")

	# Rapid Fire hits 3 tiles of the clicked enemy; Arrow Rain hits 5 across all enemies.
	_reset(HEX)
	await _play(RapidFire.new(), [_combat.enemies[0]], [Vector2i.ZERO])
	_check(_alive(_combat.enemies[0]) == 4, "Rapid Fire left %d tiles, expected 4" % _alive(_combat.enemies[0]))
	_reset(LINE, 2)
	await _play(ArrowRain.new(), [], [])
	_check(_alive(_combat.enemies[0]) + _alive(_combat.enemies[1]) == 1, "Arrow Rain didn't hit 5 tiles")

	# Enhance gives Strength, stacks, and goes to no pile.
	_reset()
	var enhance := Enhance.new()
	await _play(enhance, [], [])
	await _play(Enhance.new(), [], [])
	_check(_combat.player.power_amount(StrengthPower) == 2, "two Enhance gave %d Strength" % _combat.player.power_amount(StrengthPower))
	_check(enhance not in _combat.discard_pile + _combat.hand + _combat.draw_pile, "Enhance went back to a pile")

	# Strength: each attack also damages that many tiles next to what it hit.
	var one: Array[BaseActionTile] = [DamageTile.new(Vector2i.ZERO)]
	for strength in [1, 2]:
		_reset(HEX)
		_strengthen(_combat.player, strength)
		hits = await GridAction.new(Enum.TargetType.ENEMY, one).execute(_combat, _combat.enemies[0], Vector2i.ZERO)
		_check(hits.size() == 1 + strength, "%d Strength damaged %d tiles, expected %d" % [strength, hits.size(), 1 + strength])
		_check(hits.slice(1).all(func(c: Vector2i) -> bool: return c in StrengthPower.DIRS), "Strength hit a tile that isn't adjacent")

	# Per attack, not per damaged tile: a 3-tile line with 1 Strength damages 4.
	_reset(HEX)
	_strengthen(_combat.player, 1)
	hits = await _line().execute(_combat, _combat.enemies[0], Vector2i(-1, 0))
	_check(hits.size() == 4, "3-tile line with 1 Strength damaged %d tiles, expected 4" % hits.size())

	# No undamaged neighbour: no extra.
	_reset(HEX)
	_strengthen(_combat.player, 1)
	for dir in StrengthPower.DIRS:
		_combat.enemies[0].health[dir].hp = DAMAGED
	hits = await GridAction.new(Enum.TargetType.ENEMY, one).execute(_combat, _combat.enemies[0], Vector2i.ZERO)
	_check(hits.size() == 1, "Strength spread with no undamaged neighbour")

	# Landing on a shield or an already damaged tile still spreads.
	_reset(HEX)
	_strengthen(_combat.player, 1)
	_combat.enemies[0].health[Vector2i.ZERO].hp = SHIELDED
	hits = await GridAction.new(Enum.TargetType.ENEMY, one).execute(_combat, _combat.enemies[0], Vector2i.ZERO)
	_check(hits.size() == 1 and hits[0] != Vector2i.ZERO and _alive(_combat.enemies[0]) == 6, "a blocked hit didn't spread")
	_reset(HEX)
	_strengthen(_combat.player, 1)
	_combat.enemies[0].health[Vector2i.ZERO].hp = DAMAGED
	hits = await GridAction.new(Enum.TargetType.ENEMY, one).execute(_combat, _combat.enemies[0], Vector2i.ZERO)
	_check(hits.size() == 1 and _alive(_combat.enemies[0]) == 5, "a hit on a damaged tile didn't spread")

	# Shielded neighbours can take the extra (the shield absorbs it).
	_reset(HEX)
	_strengthen(_combat.player, 1)
	for dir in StrengthPower.DIRS:
		_combat.enemies[0].health[dir].hp = SHIELDED
	await GridAction.new(Enum.TargetType.ENEMY, one).execute(_combat, _combat.enemies[0], Vector2i.ZERO)
	_check(_shielded(_combat.enemies[0]) == 5, "Strength didn't strip a shield when only shields were left")

	# An extra never goes on a cell the attack already landed on, even if its shield was just stripped.
	_reset(HEX)
	_strengthen(_combat.player, 1)
	for cell in HEX:
		_combat.enemies[0].health[cell].hp = DAMAGED
	_combat.enemies[0].health[Vector2i(0, 0)].hp = UNDAMAGED
	_combat.enemies[0].health[Vector2i(1, 0)].hp = SHIELDED
	var pair: Array[BaseActionTile] = [DamageTile.new(Vector2i(0, 0)), DamageTile.new(Vector2i(1, 0))]
	await GridAction.new(Enum.TargetType.ENEMY, pair).execute(_combat, _combat.enemies[0], Vector2i.ZERO)
	_check(_combat.enemies[0].health[Vector2i(1, 0)].hp == UNDAMAGED, "an extra hit a cell the attack already landed on")

	# Animation: a Strength attack plays the pattern, then the extra, as two batches.
	_reset(HEX)
	_strengthen(_combat.player, 1)
	await _combat.flush()  # the Strength gain
	var batches := []
	_combat.animator = func(batch: Array[Dictionary]) -> void: batches.append(batch)
	await GridAction.new(Enum.TargetType.ENEMY, one).execute(_combat, _combat.enemies[0], Vector2i.ZERO)
	_check(batches.size() == 2 and batches.all(func(b: Array) -> bool: return b.size() == 1 and b[0].kind == Enum.Change.DAMAGE),
		"Strength attack played %s, expected the hit, then the extra" % [batches])

	# No spread on your own side's grid.
	_reset(HEX)
	_strengthen(_combat.player, 1)
	await GridAction.new(Enum.TargetType.PLAYER, one).execute(_combat, _combat.player, Vector2i.ZERO)
	_check(_alive(_combat.player) == 6, "Strength spread on your own grid")

	# Only the acting unit's Strength counts: an enemy's on its turn, not the player's.
	_reset(HEX)
	_strengthen(_combat.player, 1)
	_combat.player.in_turn = false
	_strengthen(_combat.enemies[0], 1)
	_combat.enemies[0].in_turn = true
	await GridAction.new(Enum.TargetType.PLAYER, one).execute(_combat, _combat.player, Vector2i.ZERO)
	_check(_alive(_combat.player) == 5, "enemy Strength didn't spread on its turn")
	_combat.enemies[0].statuses.clear()
	await GridAction.new(Enum.TargetType.ENEMY, one).execute(_combat, _combat.enemies[0], Vector2i.ZERO)
	_check(_alive(_combat.enemies[0]) == 6, "player Strength spread on the enemy's turn")

	# Strength counts for Thrust's condition, and spreads from random hits too.
	_reset()
	_strengthen(_combat.player, 1)
	await _play(Thrust.new(), [_combat.enemies[0]], [Vector2i(2, 0)])
	_check(_shielded(_combat.player) == 0, "Thrust didn't count the Strength hit")
	_reset(HEX)
	_strengthen(_combat.player, 1)
	await _play(RapidFire.new(), [_combat.enemies[0]], [Vector2i.ZERO])
	_check(_alive(_combat.enemies[0]) == 3, "Rapid Fire with 1 Strength left %d tiles, expected 3" % _alive(_combat.enemies[0]))
	_reset(LINE, 2)
	_strengthen(_combat.player, 1)
	await _play(ArrowRain.new(), [], [])
	_check(_alive(_combat.enemies[0]) + _alive(_combat.enemies[1]) == 0, "Arrow Rain didn't spread")

	# Picked cards and Exhaust cards go to the exhaust pile, and Retain cards stay in hand.
	_reset()
	var fuel := Strike.new()
	var kindling := Kindling.new()
	var no_units: Array[CombatUnit] = []
	var no_cells: Array[Vector2i] = []
	var no_rotations: Array[int] = []
	var picks: Array[BaseCard] = [fuel]
	_combat.hand.assign([fuel, kindling])
	_combat.energy = 1
	await _combat.play_card(kindling, no_units, no_cells, no_rotations, picks)
	_check(_combat.exhaust_pile == picks, "Kindling didn't exhaust the picked card")
	_check(kindling in _combat.discard_pile and _combat.hand.size() == 2, "Kindling didn't discard itself and draw 2")
	var last_light := LastLight.new()
	await _play(last_light, [_combat.enemies[0]], [Vector2i.ZERO])
	_check(last_light in _combat.exhaust_pile, "Last Light wasn't exhausted")
	var steady := SteadyGuard.new()
	_combat.hand.assign([steady, Strike.new()])
	_combat.discard_hand()
	_check(_combat.hand == [steady], "Steady Guard wasn't retained")

	# Cinder Strike hits 2 more random tiles once a card was exhausted this turn.
	_reset(HEX)
	await _play(CinderStrike.new(), [_combat.enemies[0]], [Vector2i.ZERO])
	_check(_alive(_combat.enemies[0]) == 4, "Cinder Strike hit extra tiles with nothing exhausted")
	_combat.exhaust(Strike.new())
	await _play(CinderStrike.new(), [_combat.enemies[0]], [Vector2i(0, 1)])
	_check(_alive(_combat.enemies[0]) == 0, "Cinder Strike didn't hit extra tiles after an exhaust")
	await _combat.start_turn()
	_check(_combat.exhausted_this_turn == 0, "the exhaust count didn't reset at turn start")

	# Mend heals the picked tiles before it's exhausted.
	_reset()
	var mend := Mend.new()
	var hurt: Array[Vector2i] = []
	hurt.assign(_combat.player.health.keys().slice(0, 2))
	for cell in hurt:
		_combat.player.health[cell].hp = DAMAGED
	var no_picks: Array[BaseCard] = []
	_combat.hand.append(mend)
	_combat.energy = 1
	await _combat.play_card(mend, no_units, no_cells, no_rotations, no_picks, hurt)
	_check(hurt.all(func(c: Vector2i) -> bool: return _combat.player.health[c].hp == UNDAMAGED), "Mend didn't heal the picked tiles")
	_check(mend in _combat.exhaust_pile, "Mend wasn't exhausted")

	# Sacrifice goes through Shield, and a Plated tile can only be picked once no open tile is left.
	_reset()
	var player_cells := _combat.player.health.keys()
	for cell in player_cells.slice(2):
		_combat.player.health[cell].hp = DAMAGED
	var open: Vector2i = player_cells[0]
	var plated: Vector2i = player_cells[1]
	_combat.player.health[open].hp = SHIELDED
	_combat.player.health[plated].status_effects.append(PlateTileEffect.new())
	var sacrifice := SacrificeTile.new(Vector2i.ZERO)
	var none_picked: Array[Vector2i] = []
	var open_picked: Array[Vector2i] = [open]
	_check(not sacrifice.can_pick(_combat.player, plated, none_picked), "a Plated tile could be sacrificed while an open one was left")
	_check(sacrifice.can_pick(_combat.player, plated, open_picked), "a Plated tile couldn't be sacrificed once the open one was picked")
	var blood_price := BloodPrice.new()
	_combat.hand.append(blood_price)
	_combat.energy = 1
	var enemy_units: Array[CombatUnit] = [_combat.enemies[0]]
	var zero_cells: Array[Vector2i] = [Vector2i.ZERO]
	var zero_rotations: Array[int] = [0]
	await _combat.play_card(blood_price, enemy_units, zero_cells, zero_rotations, no_picks, open_picked)
	_check(_combat.player.health[open].hp == DAMAGED, "Sacrifice didn't go through the Shield")
	_check(_alive(_combat.enemies[0]) == 0, "Blood Price didn't hit after the Sacrifice")

	# Retaliate hits the attacker back once per hit a Shield absorbs, and ends at the owner's next turn start.
	_reset()
	_combat.player.add_power(_combat, RetaliatePower.new(1))
	var guarded: Vector2i = _combat.player.health.keys()[0]
	var bare: Vector2i = _combat.player.health.keys()[1]
	_combat.player.health[guarded].hp = SHIELDED
	_combat.enemies[0].in_turn = true
	_combat.player.damage_health_tile(_combat, guarded)
	_check(_alive(_combat.enemies[0]) == 2, "Retaliate didn't hit back on a block")
	_combat.player.damage_health_tile(_combat, bare)
	_check(_alive(_combat.enemies[0]) == 2, "Retaliate hit back on an unshielded hit")
	_combat.enemies[0].in_turn = false
	await _combat.player.on_turn_start(_combat)
	_check(_combat.player.power_amount(RetaliatePower) == 0, "Retaliate didn't end at the next turn start")

	# Pierce damages a shielded tile and removes its Plate.
	_reset()
	_combat.enemies[0].health[LINE[0]].hp = SHIELDED
	_combat.enemies[0].health[LINE[0]].status_effects.append(PlateTileEffect.new())
	await _play(Lance.new(), [_combat.enemies[0]], [LINE[0]])
	_check(_combat.enemies[0].health[LINE[0]].hp == DAMAGED, "Pierce didn't go through the Shield")
	_check(not _combat.enemies[0].health[LINE[0]].has_effect(PlateTileEffect), "Pierce didn't remove the Plate")
	_check(_alive(_combat.enemies[0]) == 1, "Lance didn't damage 2 tiles")

	# Sunder pierces the whole line through the clicked cell, and rotating turns the line.
	_reset(HEX)
	_combat.enemies[0].health[Vector2i(1, 0)].hp = SHIELDED
	await _play(Sunder.new(), [_combat.enemies[0]], [Vector2i.ZERO])
	_check(_alive(_combat.enemies[0]) == 4, "Sunder didn't pierce the whole row")
	await Sunder.new().grid_actions[0].execute(_combat, _combat.enemies[0], Vector2i.ZERO, 1)
	_check(_alive(_combat.enemies[0]) == 2, "a rotated Sunder didn't hit the turned line")

	# Jab goes on top of the draw pile, so it's the next card drawn.
	_reset()
	var jab := Jab.new()
	await _play(jab, [_combat.enemies[0]], [Vector2i.ZERO])
	_combat.draw(1)
	_check(_combat.hand.back() == jab and jab not in _combat.discard_pile, "Jab wasn't put on top of the draw pile")

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
	unit.add_power(_combat, StrengthPower.new(amount))
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
	_check(await _combat.play_card(card, units, cells, rotations), "%s couldn't be played" % card.card_name)


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
