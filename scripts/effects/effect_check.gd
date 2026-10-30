extends SceneTree

## Headless check for Plate and Poison timing. Exit code = number of failures.
## godot --headless --path . -s res://scripts/effects/effect_check.gd

const CELL := Vector2i(0, 0)

var _failures := 0
var _combat: CombatState
var _unit: CombatUnit


func _initialize() -> void:
	var run: Node = load("res://scripts/game/run_state.gd").new()
	run.start_new_run()
	_combat = CombatState.new(run)

	# Cast during the owner's turn: no Shield until the owner's next turn.
	_reset()
	_unit.on_turn_start(_combat)
	_unit.apply_effect_health_tile(CELL, PlateTileEffect.new())
	_check(_hp() == Enum.HealthTileEnum.UNDAMAGED, "plate shielded on the casting turn")
	_next_turn()
	_check(_hp() == Enum.HealthTileEnum.SHIELDED, "unattacked plate didn't shield")

	# Attacked once (Shield absorbs it): no Shield next turn, but Plate stays.
	_end_turn()
	_hit()
	_check(_hp() == Enum.HealthTileEnum.UNDAMAGED and _plated(), "shield didn't absorb the hit")
	_start_turn()
	_check(_hp() == Enum.HealthTileEnum.UNDAMAGED, "attacked plate still shielded")
	_next_turn()
	_check(_hp() == Enum.HealthTileEnum.SHIELDED, "plate didn't shield again after a quiet turn")

	# Two hits in one turn: Shield breaks, then the tile is damaged and Plate is gone.
	_end_turn()
	_hit()
	_hit()
	_check(_hp() == Enum.HealthTileEnum.DAMAGED and not _plated(), "two hits didn't remove the plate")
	_unit.apply_effect_health_tile(CELL, PlateTileEffect.new())
	_check(not _plated(), "plate went on a damaged tile")

	# Poison fires before Plate, even when Plate was applied first.
	_reset()
	_unit.apply_effect_health_tile(CELL, PlateTileEffect.new())
	_unit.apply_effect_health_tile(CELL, PoisonTileEffect.new())
	_start_turn()
	_check(_hp() == Enum.HealthTileEnum.DAMAGED and not _plated(), "plate shielded before poison fired")

	# Poison absorbed on the owner's own turn doesn't count as an attack.
	_reset()
	_unit.apply_effect_health_tile(CELL, PlateTileEffect.new())
	_unit.shield_health_tile(CELL)
	_unit.apply_effect_health_tile(CELL, PoisonTileEffect.new())
	_start_turn()
	_check(_hp() == Enum.HealthTileEnum.SHIELDED, "own poison stopped the plate's shield")

	for keyword in ["Plate", "Poison", "Shield", "Exhaust", "Retain", "Sacrifice"]:
		_check(Keywords.describe(keyword) != "", "no tooltip for %s" % keyword)

	run.free()
	print("effect_check: %s" % ("OK" if _failures == 0 else "%d failure(s)" % _failures))
	quit(_failures)


func _reset() -> void:
	_unit = CombatUnit.new("Test", CombatUnit.make_hex_health([CELL]))


func _start_turn() -> void:
	_unit.on_turn_start(_combat)


func _end_turn() -> void:
	_unit.on_turn_end(_combat)


## Owner's turn ends, the opponent does nothing, the owner's next turn starts.
func _next_turn() -> void:
	_end_turn()
	_start_turn()


func _hit() -> void:
	_unit.damage_health_tile(_combat, CELL)


func _hp() -> int:
	return _unit.health[CELL].hp


func _plated() -> bool:
	return _unit.health[CELL].has_effect(PlateTileEffect)


func _check(ok: bool, msg: String) -> void:
	if not ok:
		_failures += 1
		printerr("FAIL: ", msg)
