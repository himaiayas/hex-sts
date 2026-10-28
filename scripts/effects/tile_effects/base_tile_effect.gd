@abstract class_name BaseTileEffect

extends BaseEffect

func _init(_name: String, _description: String, _turns := -1) -> void:
	super(_name, _description, _turns)


@abstract func get_color() -> Color
