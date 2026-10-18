class_name DamageTile
extends BaseActionTile


func _init(_coords: Vector2i)->void:
	super(_coords)

func inflict(cell: Vector2i, ctx: ActionContext)->void:
	if ctx.target.has_health_tile(cell):
		ctx.target.damage_health_tile(cell)

func get_color()->Color:
	return Color("#ff7a7a")