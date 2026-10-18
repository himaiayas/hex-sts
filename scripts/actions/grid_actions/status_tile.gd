class_name StatusTile
extends BaseActionTile

func _init(_coords: Vector2i)->void:
    super(_coords)

func inflict(cell: Vector2i, ctx: ActionContext)->void:
    pass

func get_color()->Color:
    return Color("#7a7aff")