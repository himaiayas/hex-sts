extends SceneTree

## Headless check for BaseEnemy / Slime / Goblin / Vermin / Hound / Dragon / Dracula / Ramiel. Exit code = number of failures.
## godot --headless --path . -s res://scripts/enemies/enemy_check.gd

var _failures := 0


func _initialize() -> void:
	var run: Node = load("res://scripts/game/run_state.gd").new()
	run.start_new_run()
	var combat := CombatState.new(run)
	var slime := Slime.new()
	combat.enemies.append(slime)

	# Splat -> Goo, looped. Splat damages exactly the tiles its intent shows; Goo shields 4 of its own.
	var names: Array[String] = []
	for i in 6:
		_heal(combat.player)
		_heal(slime)
		slime.plan(combat)
		var action := slime.intent_actions[0]
		names.append(action.action_name)
		var expect_damaged := {}
		for part in action.parts:
			for cell in _covered(combat.player, part):
				expect_damaged[cell] = true
		await slime.take_turn(combat)
		var damaged := _cells_with(combat.player, Enum.HealthTileEnum.DAMAGED)
		_check(damaged == expect_damaged.size() and _all_in(combat.player, expect_damaged, Enum.HealthTileEnum.DAMAGED),
			"turn %d (%s): player damage doesn't match intent" % [i, action.action_name])
		if action is EnemyShieldSelf:
			_check(_cells_with(slime, Enum.HealthTileEnum.SHIELDED) == 4, "goo should shield 4")
		_check(slime.intent_actions.is_empty(), "turn %d: intent not cleared after take_turn" % i)
	_check(names == ["Splat", "Goo", "Splat", "Goo", "Splat", "Goo"], "slime order: %s" % [names])

	await _check_goblin(combat)
	await _check_vermin(combat)
	await _check_hound(combat)
	await _check_dragon(combat)
	await _check_dracula(combat)
	await _check_ramiel(combat)

	run.free()
	print("enemy_check: %s" % ("OK" if _failures == 0 else "%d failure(s)" % _failures))
	quit(_failures)


func _check_goblin(combat: CombatState) -> void:
	var goblin := Goblin.new()
	combat.enemies = [goblin]
	var player := combat.player

	# Stab -> Backstab, looped. Stab hits 5 open tiles; Backstab pierces Shield.
	var names: Array[String] = []
	for i in 4:
		_heal(player)
		for tile in player.health.values():
			tile.hp = Enum.HealthTileEnum.SHIELDED if i % 2 else Enum.HealthTileEnum.UNDAMAGED
		goblin.plan(combat)
		var action := goblin.intent_actions[0]
		names.append(action.action_name)
		var hit := _covered(player, action.parts[0])
		await goblin.take_turn(combat)
		_check(hit.size() == (5 if i % 2 == 0 else 3) and _cells_with(player, Enum.HealthTileEnum.DAMAGED) == hit.size(),
			"goblin %s should damage %d tiles, damaged %d" % [action.action_name, 5 if i % 2 == 0 else 3, _cells_with(player, Enum.HealthTileEnum.DAMAGED)])
	_check(names == ["Stab", "Backstab", "Stab", "Backstab"], "goblin order: %s" % [names])



func _check_vermin(combat: CombatState) -> void:
	var vermin := Vermin.new()
	combat.enemies = [vermin]
	var player := combat.player

	# Gnaw -> Gnaw -> Skitter, looped. Each Gnaw lands two bites on tiles that aren't damaged yet.
	var names: Array[String] = []
	for i in 6:
		_heal(player)
		_heal(vermin)
		for cell in player.health.keys().slice(0, 12):
			player.health[cell].hp = Enum.HealthTileEnum.DAMAGED
		vermin.plan(combat)
		var action := vermin.intent_actions[0]
		names.append(action.action_name)
		if action is EnemyHit:
			for part in action.parts:
				_check(_covered(player, part).any(func(c: Vector2i) -> bool: return player.health[c].hp > Enum.HealthTileEnum.DAMAGED),
					"gnaw put a bite where nothing is left")
		await vermin.take_turn(combat)
		if action is EnemyShieldSelf:
			_check(_cells_with(vermin, Enum.HealthTileEnum.SHIELDED) == 5, "skitter should shield 5")
	_check(names == ["Gnaw", "Gnaw", "Skitter", "Gnaw", "Gnaw", "Skitter"], "vermin order: %s" % [names])



func _check_hound(combat: CombatState) -> void:
	var hound := Hound.new()
	combat.enemies = [hound]
	var player := combat.player

	# Bite (2 hits), Bite, Lunge, looped. With 3 tiles left, the two hits can't land on the same one.
	var names: Array[String] = []
	for i in 6:
		_heal(player)
		for cell in player.health.keys().slice(0, 16):
			player.health[cell].hp = Enum.HealthTileEnum.DAMAGED
		hound.plan(combat)
		var action := hound.intent_actions[0]
		names.append(action.action_name)
		var expect := {}
		for part in action.parts:
			for cell in _covered(player, part):
				if player.health[cell].hp > Enum.HealthTileEnum.DAMAGED:
					expect[cell] = true
		await hound.take_turn(combat)
		if action.parts.size() == 2:
			_check(expect.size() >= 2, "the two bites landed on the same open tile")
		_check(_cells_with(player, Enum.HealthTileEnum.DAMAGED) == 16 + expect.size(), "hound turn %d didn't damage what its intent showed" % i)
	_check(names == ["Bite", "Bite", "Lunge", "Bite", "Bite", "Lunge"], "hound order: %s" % [names])



func _check_dragon(combat: CombatState) -> void:
	var dragon := Dragon.new()
	combat.enemies = [dragon]
	var player := combat.player

	# P1 cycle.
	var names: Array[String] = []
	for i in 6:
		_heal(player)
		dragon.plan(combat)
		names.append(dragon.intent_actions[0].action_name)
		await dragon.take_turn(combat)
	_check(names == ["Claw", "Tail Sweep", "Fire Breath", "Claw", "Tail Sweep", "Fire Breath"], "dragon P1 order: %s" % [names])

	# Claw goes for open tiles before shielded ones.
	_heal(player)
	var cells := player.health.keys()
	for cell in cells.slice(0, 12):
		player.health[cell].hp = Enum.HealthTileEnum.SHIELDED
	var claw := dragon.actions[0]
	claw.plan(combat, dragon)
	var open := claw.parts[0].tiles.filter(func(t: BaseActionTile) -> bool: return player.health[t.coords].hp == Enum.HealthTileEnum.UNDAMAGED).size()
	_check(claw.parts[0].tiles.size() == 8 and open == 7, "claw should take all 7 open tiles first, took %d of %d" % [open, claw.parts[0].tiles.size()])

	# Tail Sweep: on open tiles the second row goes elsewhere; on shielded ones it follows the first.
	var sweep := dragon.actions[1]
	_heal(player)
	sweep.plan(combat, dragon)
	_check(_covered(player, sweep.parts[0]) != _covered(player, sweep.parts[1]), "tail sweep hit the same row twice on open tiles")
	for tile in player.health.values():
		tile.hp = Enum.HealthTileEnum.SHIELDED
	sweep.plan(combat, dragon)
	var first := _covered(player, sweep.parts[0])
	_check(first == _covered(player, sweep.parts[1]), "tail sweep should follow up on the shielded row")
	await sweep.execute(combat, dragon)
	_check(first.all(func(c: Vector2i) -> bool: return player.health[c].hp == Enum.HealthTileEnum.DAMAGED), "tail sweep x2 didn't damage the shielded row")

	# Inferno pierces Shield.
	for tile in player.health.values():
		tile.hp = Enum.HealthTileEnum.SHIELDED
	var inferno := dragon.actions[3]
	inferno.plan(combat, dragon)
	await inferno.execute(combat, dragon)
	var burnt := _covered(player, inferno.parts[0])
	_check(not burnt.is_empty() and burnt.all(func(c: Vector2i) -> bool: return player.health[c].hp == Enum.HealthTileEnum.DAMAGED), "inferno didn't pierce Shield")

	# P2 starts below half the tiles: 45 of 90 undamaged is still P1, 44 is P2.
	var tiles := dragon.health.values()
	for i in 45:
		tiles[i].hp = Enum.HealthTileEnum.DAMAGED
	dragon.plan(combat)
	_check(not dragon.in_p2, "dragon in P2 at exactly half its tiles")
	tiles[45].hp = Enum.HealthTileEnum.DAMAGED
	names.clear()
	for i in 5:
		_heal(player)
		dragon.plan(combat)
		names.append(dragon.intent_actions[0].action_name)
		await dragon.take_turn(combat)
	_check(names == ["Claw", "Inferno", "Tail Sweep", "Inferno", "Claw"], "dragon P2 order: %s" % [names])



func _check_dracula(combat: CombatState) -> void:
	var dracula := Dracula.new()
	combat.enemies = [dracula]
	var player := combat.player

	# P1 cycle, by index so the two Bites (heal 4 / heal 8) are told apart.
	var order: Array[int] = []
	for i in 4:
		_heal(player)
		dracula.plan(combat)
		order.append(dracula.actions.find(dracula.intent_actions[0]))
		await dracula.take_turn(combat)
	_check(order == [0, 1, 2, 0], "dracula P1 order: %s" % [order])

	# Bite heals 4 of its own damaged tiles, 8 in P2.
	for bite: DraculaBite in [dracula.actions[0], dracula.actions[3]]:
		_heal(player)
		_heal(dracula)
		var tiles := dracula.health.values()
		for i in 10:
			tiles[i].hp = Enum.HealthTileEnum.DAMAGED
		bite.plan(combat, dracula)
		await bite.execute(combat, dracula)
		_check(_cells_with(dracula, Enum.HealthTileEnum.DAMAGED) == 10 - bite.heal, "bite should heal %d" % bite.heal)

	# Blood Mist shields 10 of its own tiles.
	_heal(dracula)
	await dracula.actions[2].execute(combat, dracula)
	_check(_cells_with(dracula, Enum.HealthTileEnum.SHIELDED) == 10, "blood mist should shield 10")

	# Bat Swarm and Crimson Rain land every hit on a tile that isn't damaged yet.
	for scattered in [dracula.actions[1], dracula.actions[4]]:
		for i in 20:
			_heal(player)
			for cell in player.health.keys().slice(0, 12):
				player.health[cell].hp = Enum.HealthTileEnum.DAMAGED
			scattered.plan(combat, dracula)
			for part in scattered.parts:
				_check(_covered(player, part).any(func(c: Vector2i) -> bool: return player.health[c].hp > Enum.HealthTileEnum.DAMAGED),
					"%s put a hit where nothing is left" % scattered.action_name)

	# Each hit plays on its own: one animated batch per bat and per wave.
	for scattered in [dracula.actions[1], dracula.actions[4]]:
		_heal(player)
		var batches := []
		combat.animator = func(batch: Array[Dictionary]) -> void: batches.append(batch)
		scattered.plan(combat, dracula)
		await scattered.execute(combat, dracula)
		combat.animator = Callable()
		_check(batches.size() == scattered.parts.size(), "%s played %d hits, not %d" % [scattered.action_name, batches.size(), scattered.parts.size()])

	# P2 below half its tiles.
	_heal(dracula)
	var tiles := dracula.health.values()
	for i in 66:
		tiles[i].hp = Enum.HealthTileEnum.DAMAGED
	order.clear()
	for i in 4:
		_heal(player)
		dracula.plan(combat)
		order.append(dracula.actions.find(dracula.intent_actions[0]))
		await dracula.take_turn(combat)
		for t in tiles.slice(0, 66):  # keep it below half despite the Bite heals
			t.hp = Enum.HealthTileEnum.DAMAGED
	_check(order == [3, 4, 2, 3], "dracula P2 order: %s" % [order])



func _check_ramiel(combat: CombatState) -> void:
	var player := combat.player
	var ramiel := Ramiel.new()
	combat.enemies = [ramiel]
	_check(RamielField.shields(ramiel) == 20, "ramiel should start with 20 shields")

	# P1: Scan -> Charge x3 (counting down, beam locked) -> Particle Beam (Pierce) -> Scan.
	var turns: Array[String] = []
	var locked := Vector2i.ZERO
	for i in 6:
		_heal(player)
		ramiel.plan(combat)
		turns.append(_rows(ramiel))
		var charge := ramiel.intent_actions.filter(func(a: BaseEnemyAction) -> bool: return a is RamielCharge)
		if i == 1:
			locked = charge[0].parts[0].cell
		elif not charge.is_empty():
			_check(charge[0].parts[0].cell == locked, "charge %d moved the beam" % i)
		if i == 4:
			for tile in player.health.values():
				tile.hp = Enum.HealthTileEnum.SHIELDED
			var beam: RamielParticleBeam = ramiel.intent_actions.back()
			_check(beam.parts[0].cell == locked, "beam didn't fire where the charges aimed")
			await ramiel.take_turn(combat)
			var burnt := _covered(player, beam.parts[0])
			_check(not burnt.is_empty() and burnt.all(func(c: Vector2i) -> bool: return player.health[c].hp == Enum.HealthTileEnum.DAMAGED), "beam didn't pierce Shield")
		else:
			await ramiel.take_turn(combat)
	_check(turns == ["Scan", "Charge: 3 turns (0/20)", "Charge: 2 turns (0/20)",
		"Charge: 1 turn (0/20)", "Particle Beam", "Scan"], "ramiel P1 turns: %s" % [turns])

	# Interrupt: 19 lost tiles don't, the 20th turns the Charge into Stunned at once; then it starts over.
	ramiel = Ramiel.new()
	combat.enemies = [ramiel]
	for i in 2:
		ramiel.plan(combat)
		if i == 0:
			await ramiel.take_turn(combat)
	var open: Array = ramiel.health.keys()
	for i in 19:
		ramiel.damage_health_tile(combat, open[i], true)
	_check(_rows(ramiel) == "Charge: 3 turns (19/20)", "19 lost tiles: %s" % _rows(ramiel))
	ramiel.damage_health_tile(combat, open[19], true)
	_check(_rows(ramiel) == "Stunned", "20 lost tiles should stun, got %s" % _rows(ramiel))
	_heal(player)
	await ramiel.take_turn(combat)
	_check(_cells_with(player, Enum.HealthTileEnum.DAMAGED) == 0, "a stunned ramiel attacked")
	ramiel.plan(combat)
	_check(_rows(ramiel) == "Scan", "after the stun the cycle should start over, got %s" % _rows(ramiel))

	# P2 from a cycle boundary: Charge x2 with a Shard Drill each -> Particle Beam.
	ramiel = Ramiel.new()
	combat.enemies = [ramiel]
	var tiles := ramiel.health.values()
	for i in 86:
		tiles[i].hp = Enum.HealthTileEnum.DAMAGED
	turns.clear()
	for i in 4:
		_heal(player)
		ramiel.plan(combat)
		turns.append(_rows(ramiel).replace("Absolute Terror Field\n", ""))
		await ramiel.take_turn(combat)
	_check(turns == ["Charge: 2 turns (0/20)\nShard Drill", "Charge: 1 turn (0/20)\nShard Drill",
		"Particle Beam", "Charge: 2 turns (0/20)\nShard Drill"], "ramiel P2 turns: %s" % [turns])

	# Field: every 3rd turn, first in the turn; marked tiles destroyed before it runs stay unshielded.
	ramiel = Ramiel.new()
	combat.enemies = [ramiel]
	var shielded: Array = ramiel.health.keys().filter(func(c: Vector2i) -> bool: return ramiel.health[c].hp == Enum.HealthTileEnum.SHIELDED)
	for cell in shielded.slice(5):
		ramiel.health[cell].hp = Enum.HealthTileEnum.UNDAMAGED
	ramiel._turns = 2
	ramiel._step = 1  # a Charge turn, so no Scan joins in
	ramiel.plan(combat)
	var field: BaseEnemyAction = ramiel.intent_actions[0]
	_check(field is RamielField and field.parts[0].tiles.size() == 15, "field should plan 15 tiles first in the turn")
	for t in field.parts[0].tiles.slice(0, 2):
		ramiel.health[t.coords].hp = Enum.HealthTileEnum.DAMAGED
	await ramiel.take_turn(combat)
	_check(RamielField.shields(ramiel) == 18, "field should shield 13 surviving marks, has %d shields" % RamielField.shields(ramiel))
	# At 20 Shields it's skipped, but the turn still counts.
	ramiel._turns = 5
	for cell in ramiel.health:
		if RamielField.shields(ramiel) < 20 and ramiel.health[cell].hp == Enum.HealthTileEnum.UNDAMAGED:
			ramiel.health[cell].hp = Enum.HealthTileEnum.SHIELDED
	ramiel.plan(combat)
	_check(not _rows(ramiel).contains("Absolute Terror Field") and ramiel._turns == 6, "field at 20 shields should be skipped")
	# Field + Scan on the same turn: 20, then 15 more.
	ramiel = Ramiel.new()
	combat.enemies = [ramiel]
	for cell in ramiel.health:
		if ramiel.health[cell].hp == Enum.HealthTileEnum.SHIELDED:
			ramiel.health[cell].hp = Enum.HealthTileEnum.UNDAMAGED
	ramiel._turns = 2
	ramiel.plan(combat)
	_check(_rows(ramiel) == "Absolute Terror Field\nScan", "field + scan rows: %s" % _rows(ramiel))
	await ramiel.take_turn(combat)
	_check(RamielField.shields(ramiel) == 35, "field + scan should make 35 shields, has %d" % RamielField.shields(ramiel))


## A unit's intent label: one row per move.
func _rows(enemy: BaseEnemy) -> String:
	return "\n".join(PackedStringArray(enemy.intent_actions.map(func(a: BaseEnemyAction) -> String: return a.intent_text())))


## Cells of unit's grid that a planned part covers.
func _covered(unit: CombatUnit, part: EnemyActionPart) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for t in part.tiles:
		if unit.health.has(part.cell + t.coords):
			cells.append(part.cell + t.coords)
	cells.sort()
	return cells


func _check(ok: bool, msg: String) -> void:
	if not ok:
		_failures += 1
		printerr("FAIL: ", msg)


func _heal(unit: CombatUnit) -> void:
	for tile in unit.health.values():
		tile.hp = Enum.HealthTileEnum.UNDAMAGED
		tile.status_effects.clear()


func _cells_with(unit: CombatUnit, hp: int) -> int:
	return unit.health.values().filter(func(t: HealthTile) -> bool: return t.hp == hp).size()


func _all_in(unit: CombatUnit, cells: Dictionary, hp: int) -> bool:
	for cell in cells:
		if unit.health[cell].hp != hp:
			return false
	return true
