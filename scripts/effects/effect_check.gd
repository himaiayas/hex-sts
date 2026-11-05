extends SceneTree

## Headless check for Plate and Poison timing. Exit code = number of failures.
## godot --headless --path . -s res://scripts/effects/effect_check.gd

const CELL := Vector2i(0, 0)
const OTHER := Vector2i(1, 0)

var _failures := 0
var _combat: CombatState
var _unit: CombatUnit


func _initialize() -> void:
	var run: Node = load("res://scripts/game/run_state.gd").new()
	run.start_new_run()
	_combat = CombatState.new(run)

	# Cast during the owner's turn: no Shield until the owner's next turn.
	_reset()
	await _unit.on_turn_start(_combat)
	_unit.apply_effect_health_tile(_combat, CELL, PlateTileEffect.new())
	_check(_hp() == Enum.HealthTileEnum.UNDAMAGED, "plate shielded on the casting turn")
	await _next_turn()
	_check(_hp() == Enum.HealthTileEnum.SHIELDED, "unattacked plate didn't shield")

	# Attacked once (Shield absorbs it): no Shield next turn, but Plate stays.
	await _end_turn()
	_hit()
	_check(_hp() == Enum.HealthTileEnum.UNDAMAGED and _plated(), "shield didn't absorb the hit")
	await _start_turn()
	_check(_hp() == Enum.HealthTileEnum.UNDAMAGED, "attacked plate still shielded")
	await _next_turn()
	_check(_hp() == Enum.HealthTileEnum.SHIELDED, "plate didn't shield again after a quiet turn")

	# Two hits in one turn: Shield breaks, then the tile is damaged and Plate is gone.
	await _end_turn()
	_hit()
	_hit()
	_check(_hp() == Enum.HealthTileEnum.DAMAGED and not _plated(), "two hits didn't remove the plate")
	_unit.apply_effect_health_tile(_combat, CELL, PlateTileEffect.new())
	_check(not _plated(), "plate went on a damaged tile")

	# Poison fires before Plate, even when Plate was applied first.
	_reset()
	_unit.apply_effect_health_tile(_combat, CELL, PlateTileEffect.new())
	_unit.apply_effect_health_tile(_combat, CELL, PoisonTileEffect.new())
	await _start_turn()
	_check(_hp() == Enum.HealthTileEnum.DAMAGED and not _plated(), "plate shielded before poison fired")

	# Poison absorbed on the owner's own turn doesn't count as an attack.
	_reset()
	_unit.apply_effect_health_tile(_combat, CELL, PlateTileEffect.new())
	_unit.shield_health_tile(_combat, CELL)
	_unit.apply_effect_health_tile(_combat, CELL, PoisonTileEffect.new())
	await _start_turn()
	_check(_hp() == Enum.HealthTileEnum.SHIELDED, "own poison stopped the plate's shield")

	# Each effect plays on its own at turn start: Poison's hit, then Plate's shield.
	_unit = CombatUnit.new("Test", CombatUnit.make_hex_health([CELL, OTHER]))
	_unit.apply_effect_health_tile(_combat, CELL, PoisonTileEffect.new())
	_unit.apply_effect_health_tile(_combat, OTHER, PlateTileEffect.new())
	await _combat.flush()
	var batches := []
	_combat.animator = func(batch: Array[Dictionary]) -> void: batches.append(batch)
	await _start_turn()
	_combat.animator = Callable()
	_check(batches.map(func(b: Array) -> Array: return b.map(func(c: Dictionary) -> int: return c.kind))
		== [[Enum.Change.DAMAGE], [Enum.Change.SHIELD]], "turn start played %s, expected Poison then Plate" % [batches])

	for keyword in ["Plate", "Poison", "Shield", "Exhaust", "Retain", "Sacrifice"]:
		_check(Keywords.describe(keyword) != "", "no tooltip for %s" % keyword)

	run.free()
	print("effect_check: %s" % ("OK" if _failures == 0 else "%d failure(s)" % _failures))
	quit(_failures)


func _reset() -> void:
	_unit = CombatUnit.new("Test", CombatUnit.make_hex_health([CELL]))


func _start_turn() -> void:
	await _unit.on_turn_start(_combat)


func _end_turn() -> void:
	await _unit.on_turn_end(_combat)


## Owner's turn ends, the opponent does nothing, the owner's next turn starts.
func _next_turn() -> void:
	await _end_turn()
	await _start_turn()


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
