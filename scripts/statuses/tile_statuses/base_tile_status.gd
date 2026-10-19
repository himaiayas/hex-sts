@abstract class_name BaseTileStatus
extends BaseStatus

func _init(_name: String, _description: String) -> void:
    super(_name, _description)


@abstract func get_color() -> Color