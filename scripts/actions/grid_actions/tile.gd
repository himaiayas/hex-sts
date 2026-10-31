@abstract class_name BaseActionTile
extends Resource

var coords:Vector2i

func _init(_coords:Vector2i)->void:
	self.coords=_coords

## Returns true if it changed the tile.
@abstract
func inflict(combat: CombatState, unit: CombatUnit, cell: Vector2i)->bool

## Whether inflict would do anything at cell. Random actions only pick cells that pass this.
func can_inflict(unit: CombatUnit, cell: Vector2i)->bool:
	return unit.health.has(cell) and unit.health[cell].hp != Enum.HealthTileEnum.DAMAGED

@abstract
func get_color()->Color

## Drawn on targeted health tiles (intents, previews). Null: draw get_color() instead.
func get_icon() -> Texture2D:
	return null
