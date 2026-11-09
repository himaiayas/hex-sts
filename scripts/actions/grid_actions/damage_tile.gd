class_name DamageTile
extends BaseActionTile

var pierce := false  # goes through Shield (and so Plate): the tile is damaged even if shielded


func _init(_coord: Vector2i, _pierce := false)->void:
	super(_coord)
	pierce = _pierce

## True only when the tile ends up damaged, not when a shield blocks it.
func inflict(combat: CombatState, unit: CombatUnit, cell: Vector2i)->bool:
	return unit.health.has(cell) and unit.damage_health_tile(combat, cell, pierce)

func get_color()->Color:
	return Color("#ff7a7a")

## Pierce (and so Sacrifice) has its own icon.
func get_icon() -> Texture2D:
	return preload("res://assets/grid_effects/piercing.png") if pierce else preload("res://assets/grid_effects/damage.png")

func describe() -> String:
	return "Damages this tile, ignore Shield." if pierce else "Damages this tile. Can be Blocked by Shield."

func display_name() -> String:
	return "Pierce" if pierce else "Damage"

func copy_at(at: Vector2i) -> BaseActionTile:
	return DamageTile.new(at, pierce)

func kind() -> String:
	return super() + ("|pierce" if pierce else "")
