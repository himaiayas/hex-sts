class_name CombatUnit
extends RefCounted

signal blocked(coords: Vector2i)  # a Shield absorbed a hit on this tile

var display_name: String
var health: Dictionary[Vector2i, HealthTile]  #Matrix with element as HealthTile
var statuses: Array[BaseEffect] = []
var artifacts: Array[BaseArtifact] = []  # the player's, shared with RunState
var is_player := false
var in_turn := false  # true between this unit's TURN_START and TURN_END


func _init(_name: String, _health: Dictionary[Vector2i, HealthTile], _is_player := false) -> void:
	display_name = _name
	health = _health
	is_player = _is_player


## One undamaged tile per coord, keyed by axial (q, r).
static func make_hex_health(coords: Array[Vector2i]) -> Dictionary[Vector2i, HealthTile]:
	var health_dict: Dictionary[Vector2i, HealthTile] = {}
	for coord in coords:
		health_dict[coord] = HealthTile.new()
	return health_dict

func shield_health_tile(combat: CombatState, coords:Vector2i)->void:
	var tile: HealthTile = health[coords]

	if tile and tile.hp>Enum.HealthTileEnum.DAMAGED:
		if CurseWrapPower.fizzles(combat, self):
			return
		if tile.hp == Enum.HealthTileEnum.UNDAMAGED:
			combat.record(self, coords, Enum.Change.SHIELD)
		tile.hp = Enum.HealthTileEnum.SHIELDED
	

## A power can make the hit miss (Aerial, Ethereal: it flashes like a block, with no trigger). Otherwise Shield absorbs it
## first (ON_BLOCK), unless it pierces, and then the tile is damaged (ON_HIT).
## Returns true if the tile was damaged.
func damage_health_tile(combat: CombatState, coords: Vector2i, pierce := false)->bool:
	var tile: HealthTile = health[coords]
	if tile.hp > Enum.HealthTileEnum.DAMAGED:
		for power in statuses:
			if power is BasePower and power.dodges(combat, self):
				combat.record(self, coords, Enum.Change.BLOCK)
				return false
	if tile.hp == Enum.HealthTileEnum.SHIELDED and not pierce and not PiercingPower.active(combat, self):
		tile.hp = Enum.HealthTileEnum.UNDAMAGED
		combat.record(self, coords, Enum.Change.BLOCK)
		fire_at(Enum.Trigger.ON_BLOCK, combat, coords)
		blocked.emit(coords)
	elif tile.hp > Enum.HealthTileEnum.DAMAGED:
		tile.hp = Enum.HealthTileEnum.DAMAGED
		combat.record(self, coords, Enum.Change.DAMAGE)
		fire_at(Enum.Trigger.ON_HIT, combat, coords)
		return true
	return false


## Returns true if the tile was damaged and is now healed.
func heal_health_tile(combat: CombatState, coords: Vector2i) -> bool:
	if health[coords].hp != Enum.HealthTileEnum.DAMAGED:
		return false
	health[coords].hp = Enum.HealthTileEnum.UNDAMAGED
	combat.record(self, coords, Enum.Change.HEAL)
	return true


func apply_effect_health_tile(combat: CombatState, coords:Vector2i, effect:BaseTileEffect)->void:
	var tile: HealthTile = health[coords]
	if tile and (tile.hp > Enum.HealthTileEnum.DAMAGED or effect.allow_damaged):
		if effect is PlateTileEffect and CurseWrapPower.fizzles(combat, self):
			return
		var is_new := not tile.has_effect(effect.get_script())
		_add_or_stack(tile.status_effects, effect)
		combat.record(self, coords, Enum.Change.EFFECT, effect)
		if is_new:
			for power in statuses.duplicate():
				if power is BasePower:
					power.on_tile_effect_gained(combat, self, coords, effect)


func add_power(combat: CombatState, power: BaseEffect) -> void:
	_add_or_stack(statuses, power)
	combat.record(self, Vector2i.ZERO, Enum.Change.POWER, power)


## Stacks of the power with this script, 0 if the unit doesn't have it.
func power_amount(script: Script) -> int:
	for power in statuses:
		if power.get_script() == script and power is BasePower:
			return power.amount
	return 0


func on_turn_start(combat: CombatState) -> void:
	in_turn = true
	await fire(Enum.Trigger.TURN_START, combat)


## Fires TURN_END, then counts every effect down and drops the ones that ran out.
func on_turn_end(combat: CombatState) -> void:
	await fire(Enum.Trigger.TURN_END, combat)
	in_turn = false
	statuses.assign(statuses.filter(_still_active))
	for tile in health.values():
		tile.status_effects.assign(tile.status_effects.filter(_still_active))


## Runs trigger on every artifact, power and tile effect, and plays what each one changed in turn.
func fire(trigger: Enum.Trigger, combat: CombatState) -> void:
	for artifact in artifacts.duplicate():
		artifact.on_trigger(trigger, combat, self, Vector2i.ZERO)
		await combat.flush()
	for power in statuses.duplicate():
		power.on_trigger(trigger, combat, self, Vector2i.ZERO)
		await combat.flush()
	for cell in health:
		for effect in health[cell].status_effects.duplicate():
			effect.on_trigger(trigger, combat, self, cell)
			await combat.flush()


## Runs trigger on every artifact and power, and on the effects of the tile at cell.
## No flush: what they change plays together with the hit that fired them.
func fire_at(trigger: Enum.Trigger, combat: CombatState, cell: Vector2i) -> void:
	for artifact in artifacts.duplicate():
		artifact.on_trigger(trigger, combat, self, cell)
	for power in statuses.duplicate():
		power.on_trigger(trigger, combat, self, cell)
	for effect in health[cell].status_effects.duplicate():
		effect.on_trigger(trigger, combat, self, cell)


func _add_or_stack(effects: Array, effect: BaseEffect) -> void:
	for existing in effects:
		if existing.get_script() == effect.get_script():
			existing.stack(effect)
			return
	effects.append(effect)
	effects.sort_custom(func(a: BaseEffect, b: BaseEffect) -> bool: return a.order < b.order)


func _still_active(effect: BaseEffect) -> bool:
	return not effect.tick()


## Dead once every health tile is damaged.
func is_dead() -> bool:
	for tile in health.values():
		if tile.hp > Enum.HealthTileEnum.DAMAGED:
			return false
	return true
