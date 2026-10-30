extends SceneTree

## Headless check for BaseEnemy / Slime. Exit code = number of failures.
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

		slime.take_turn(combat)

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

	run.free()
	print("enemy_check: %s" % ("OK" if _failures == 0 else "%d failure(s)" % _failures))
	quit(_failures)


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
