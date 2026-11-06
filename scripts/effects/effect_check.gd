extends SceneTree

## Headless check for Plate and Poison timing. Exit code = number of failures.
## godot --headless --path . -s res://scripts/effects/effect_check.gd

const CELL := Vector2i(0, 0)
const OTHER := Vector2i(1, 0)
const HEX: Array[Vector2i] = [
	Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 1),
	Vector2i(-1, 0), Vector2i(0, -1), Vector2i(1, -1),
]

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

	# Poison waits one turn start, then explodes at the next: through Shield and Plate on its tile,
	# 1 hit on each neighbour (a Shield there absorbs it).
	_unit = CombatUnit.new("Test", CombatUnit.make_hex_health(HEX))
	_unit.apply_effect_health_tile(_combat, CELL, PlateTileEffect.new())
	_unit.shield_health_tile(_combat, CELL)
	_unit.shield_health_tile(_combat, OTHER)
	_unit.apply_effect_health_tile(_combat, CELL, PoisonTileEffect.new())
	await _start_turn()
	_check(_alive() == 7 and _poisoned(CELL), "poison exploded on the first turn start")
	await _next_turn()
	_check(_hp() == Enum.HealthTileEnum.DAMAGED and not _plated() and not _poisoned(CELL), "poison didn't pierce its own tile")
	_check(_alive() == 1 and _unit.health[OTHER].hp == Enum.HealthTileEnum.UNDAMAGED, "poison didn't hit each neighbour once")

	# Poison stays on a damaged tile, can go on one, and a second Poison doesn't reset the countdown.
	_unit = CombatUnit.new("Test", CombatUnit.make_hex_health(HEX))
	_unit.apply_effect_health_tile(_combat, CELL, PoisonTileEffect.new())
	_hit()
	_check(_poisoned(CELL), "poison left a damaged tile")
	await _start_turn()
	_unit.apply_effect_health_tile(_combat, CELL, PoisonTileEffect.new())
	_unit.apply_effect_health_tile(_combat, OTHER, PoisonTileEffect.new())
	_unit.damage_health_tile(_combat, OTHER)
	await _next_turn()
	_check(not _poisoned(CELL) and _alive() == 0, "a second poison reset the countdown")
	_check(_poisoned(OTHER), "a poisoned neighbour exploded with it instead of on its own countdown")

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


func _poisoned(cell: Vector2i) -> bool:
	return _unit.health[cell].has_effect(PoisonTileEffect)


func _alive() -> int:
	return _unit.health.values().filter(func(t: HealthTile) -> bool: return t.hp != Enum.HealthTileEnum.DAMAGED).size()


func _plated() -> bool:
	return _unit.health[CELL].has_effect(PlateTileEffect)


func _check(ok: bool, msg: String) -> void:
	if not ok:
		_failures += 1
		printerr("FAIL: ", msg)
