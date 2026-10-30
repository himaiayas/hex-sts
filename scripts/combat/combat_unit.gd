class_name CombatUnit
extends RefCounted


var display_name: String
var health: Dictionary[Vector2i, HealthTile]  #Matrix with element as HealthTile
var statuses: Array[BaseEffect] = []
var artifacts: Array[BaseArtifact] = []  # the player's, shared with RunState
var is_player := false


func _init(_name: String, _health: Dictionary[Vector2i, HealthTile], _is_player := false) -> void:
	display_name = _name
	health = _health
	is_player = _is_player


## hexagon of radius r in a (2r+1)x(2r+1) matrix
static func make_hex_health(coords: Array[Vector2i]) -> Dictionary[Vector2i, HealthTile]:
	var health_dict: Dictionary[Vector2i, HealthTile] = {}
	for coord in coords:
		health_dict[coord] = HealthTile.new()
	return health_dict

func shield_health_tile(coords:Vector2i)->void:
	var tile: HealthTile = health[coords]

	if tile and tile.hp>Enum.HealthTileEnum.DAMAGED:
		tile.hp = Enum.HealthTileEnum.SHIELDED
	

## Shield absorbs the hit first (ON_BLOCK); otherwise the tile is damaged (ON_HIT).
func damage_health_tile(combat: CombatState, coords: Vector2i)->void:
	var tile: HealthTile = health[coords]
	if tile.hp == Enum.HealthTileEnum.SHIELDED:
		tile.hp = Enum.HealthTileEnum.UNDAMAGED
		fire_at(Enum.Trigger.ON_BLOCK, combat, coords)
	elif tile.hp == Enum.HealthTileEnum.UNDAMAGED:
		tile.hp = Enum.HealthTileEnum.DAMAGED
		fire_at(Enum.Trigger.ON_HIT, combat, coords)


func apply_effect_health_tile(coords:Vector2i, effect:BaseTileEffect)->void:
	var tile: HealthTile = health[coords]
	if tile:
		_add_or_stack(tile.status_effects, effect)


func add_power(power: BaseEffect) -> void:
	_add_or_stack(statuses, power)


func on_turn_start(combat: CombatState) -> void:
	fire(Enum.Trigger.TURN_START, combat)


## Fires TURN_END, then counts every effect down and drops the ones that ran out.
func on_turn_end(combat: CombatState) -> void:
	fire(Enum.Trigger.TURN_END, combat)
	statuses.assign(statuses.filter(_still_active))
	for tile in health.values():
		tile.status_effects.assign(tile.status_effects.filter(_still_active))


## Runs trigger on every artifact, power and tile effect.
func fire(trigger: Enum.Trigger, combat: CombatState) -> void:
	for artifact in artifacts.duplicate():
		artifact.on_trigger(trigger, combat, self, Vector2i.ZERO)
	for power in statuses.duplicate():
		power.on_trigger(trigger, combat, self, Vector2i.ZERO)
	for cell in health:
		for effect in health[cell].status_effects.duplicate():
			effect.on_trigger(trigger, combat, self, cell)


## Runs trigger on every artifact and power, and on the effects of the tile at cell.
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


func _still_active(effect: BaseEffect) -> bool:
	return not effect.tick()


## Dead once every health tile is damaged.
func is_dead() -> bool:
	for tile in health.values():
		if tile.hp > Enum.HealthTileEnum.DAMAGED:
			return false
	return true
