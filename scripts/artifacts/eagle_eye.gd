class_name EagleEye
extends BaseArtifact


func _init() -> void:
	super("Eagle Eye", "When your attack lands on an enemy's edge tile, damage 1 more random edge tile of that enemy.", Enum.ArtifactRarity.UNCOMMON,
		preload("res://assets/artifacts/eagle_eye.png"))

## Edge tile: fewer than 6 neighbours on its grid. Once per enemy per attack, never a tile it landed on.
func on_attack_landed(combat: CombatState, landed: Array) -> Array[Vector2i]:
	var extras: Array[Vector2i] = []
	var done: Array[CombatUnit] = []
	for hit in landed:
		var unit: CombatUnit = hit[0]
		if unit.is_player or unit in done or not _is_edge(unit, hit[1]):
			continue
		done.append(unit)
		var cells := unit.health.keys().filter(func(c: Vector2i) -> bool:
			return _is_edge(unit, c) and undamaged(unit.health[c]) and [unit, c] not in landed)
		if cells.is_empty():
			continue
		var cell: Vector2i = cells.pick_random()
		if unit.damage_health_tile(combat, cell):
			extras.append(cell)
	return extras


static func _is_edge(unit: CombatUnit, cell: Vector2i) -> bool:
	return DIRS.any(func(d: Vector2i) -> bool: return not unit.health.has(cell + d))
