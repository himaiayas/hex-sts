extends SceneTree

## Headless check for BaseEnemy / Slime / Dragon. Exit code = number of failures.
## godot --headless --path . -s res://scripts/enemies/enemy_check.gd

var _failures := 0


func _initialize() -> void:
	var run: Node = load("res://scripts/game/run_state.gd").new()
	run.start_new_run()
	var combat := CombatState.new(run)
	var slime := Slime.new()
	combat.enemies.append(slime)

	var seen := {}
	for i in 60:
		_heal(combat.player)
		_heal(slime)
		slime.plan(combat)
		var action := slime.intent_action
		seen[action.action_name] = true

		# What the intent shows, per grid.
		var expect_damaged := {}
		var expect_plated := {}
		for part in action.parts:
			var target: CombatUnit = combat.player if part.side == Enum.Side.PLAYER else slime
			for t in part.tiles:
				var cell := part.cell + t.coords
				if not target.health.has(cell):
					continue
				if t is DamageTile:
					expect_damaged[cell] = true
				elif t is ApplyEffectTile and t.effect is PlateTileEffect:
					expect_plated[cell] = true

		await slime.take_turn(combat)

		# What actually happened must match the intent exactly.
		var damaged := _cells_with(combat.player, Enum.HealthTileEnum.DAMAGED)
		var plated := slime.health.values().filter(func(t: HealthTile) -> bool: return t.has_effect(PlateTileEffect)).size()
		_check(damaged == expect_damaged.keys().size() and _all_in(combat.player, expect_damaged, Enum.HealthTileEnum.DAMAGED),
			"turn %d (%s): player damage doesn't match intent" % [i, action.action_name])
		_check(plated == expect_plated.keys().size() and expect_plated.keys().all(func(c: Vector2i) -> bool: return slime.health[c].has_effect(PlateTileEffect)),
			"turn %d (%s): self plate doesn't match intent" % [i, action.action_name])
		_check(slime.intent_action == null, "turn %d: intent not cleared after take_turn" % i)

	for name in ["Slime Attack 1", "Harden", "Guarded Bash"]:
		_check(seen.has(name), "action %s never chosen in 60 plans" % name)

	await _check_dragon(combat)

	run.free()
	print("enemy_check: %s" % ("OK" if _failures == 0 else "%d failure(s)" % _failures))
	quit(_failures)


func _check_dragon(combat: CombatState) -> void:
	var dragon := Dragon.new()
	combat.enemies = [dragon]
	var player := combat.player

	# P1 cycle.
	var names: Array[String] = []
	for i in 6:
		_heal(player)
		dragon.plan(combat)
		names.append(dragon.intent_action.action_name)
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
		names.append(dragon.intent_action.action_name)
		await dragon.take_turn(combat)
	_check(names == ["Claw", "Inferno", "Tail Sweep", "Inferno", "Claw"], "dragon P2 order: %s" % [names])


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
