@abstract class_name BaseTileEffect

extends BaseEffect

var allow_damaged := false  # can be applied to a damaged tile (Poison); other effects can't
var debuff := false  # harmful to the tile's owner (Fracture, Poison); Cleanse removes these

func _init(_name: String, _description: String, _turns := -1) -> void:
	super(_name, _description, _turns)


@abstract func get_color() -> Color

## Shown where an attack would apply this effect. Null: use get_color().
func get_icon() -> Texture2D:
	return null
