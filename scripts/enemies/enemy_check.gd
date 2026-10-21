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

	var names: Array[String] = []
	for i in 3:
		_heal(combat.player)
		slime.plan(combat.player)
		names.append(slime.intent_action.display_name)
		var score := slime._score_cell(slime.intent_action as GridAction, slime.intent_cell, combat.player)
		_check(score == 4, "turn %d: planned score %d, expected 4" % [i, score])
		slime.take_turn(combat)
		var damaged := _damaged(combat.player)
		_check(damaged == 2, "turn %d: %d cells damaged, expected 2" % [i, damaged])
	_check(",".join(names) == "Tackle,Lunge,Tackle", "loop order %s" % [names])

	run.free()
	print("enemy_check: %s" % ("OK" if _failures == 0 else "%d failure(s)" % _failures))
	quit(_failures)


func _check(ok: bool, msg: String) -> void:
	if not ok:
		_failures += 1
		printerr("FAIL: ", msg)


func _heal(unit: CombatUnit) -> void:
	for tile in unit.health.values():
		tile.hp = HealthTile.HealthTileEnum.UNDAMAGED


func _damaged(unit: CombatUnit) -> int:
	return unit.health.values().filter(func(t: HealthTile) -> bool: return t.hp == HealthTile.HealthTileEnum.DAMAGED).size()
