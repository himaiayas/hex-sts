class_name AtFieldTileEffect
extends BaseTileEffect

## AT Field (Ramiel's Absolute Terror Field): the tile can't be damaged while its owner has any
## other undamaged tile without AT Field, Pierce or not. CombatUnit.damage_health_tile checks it.

const COLOR := Color("#8a6cff")  # blue-violet


func _init() -> void:
	super("AT Field", "This tile can't be damaged while its owner has any other undamaged tile without AT Field.")


func get_color() -> Color:
	return COLOR


func get_icon() -> Texture2D:
	return preload("res://assets/grid_effects/at_field.png")


## Whether unit's tile at cell is protected now: it has AT Field and some other undamaged tile doesn't.
static func protects(unit: CombatUnit, cell: Vector2i) -> bool:
	if not unit.health.has(cell) or not unit.health[cell].has_effect(AtFieldTileEffect):
		return false
	for other: Vector2i in unit.health:
		var tile: HealthTile = unit.health[other]
		if other != cell and tile.hp > Enum.HealthTileEnum.DAMAGED and not tile.has_effect(AtFieldTileEffect):
			return true
	return false
