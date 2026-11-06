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

## Whether the player can pick cell in a pick step (e.g. Heal), with picked already chosen.
func can_pick(unit: CombatUnit, cell: Vector2i, _picked: Array[Vector2i])->bool:
	return can_inflict(unit, cell)

## Drawn on targeted health tiles (intents, previews). Null: draw get_color() instead.
func get_icon() -> Texture2D:
	return null

## Shown when choosing between tiles (e.g. Expansion Augment).
@abstract
func display_name() -> String

## Same action at other coords (Expansion Augment copies a neighbour this way).
func copy_at(at: Vector2i) -> BaseActionTile:
	return get_script().new(at)

## Tiles with the same kind do the same thing.
func kind() -> String:
	return get_script().resource_path
