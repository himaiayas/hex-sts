class_name SacrificeTile
extends DamageTile

## Destroys one of your own tiles as a cost: Damage that pierces, so a Shield doesn't absorb it.
## Put it in a must_land GridAction on the player's grid, so it can't go on a damaged tile or off the grid.


func _init(_coord: Vector2i)->void:
	super(_coord, true)

func get_color()->Color:
	return Color("#b03a48")

func describe() -> String:
	return "Destroys one of your own undamaged tiles, even through Shield."

func display_name() -> String:
	return "Sacrifice"

func copy_at(at: Vector2i) -> BaseActionTile:
	return SacrificeTile.new(at)
