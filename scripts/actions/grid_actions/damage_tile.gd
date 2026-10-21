class_name DamageTile
extends BaseActionTile


func _init(_coord: Vector2i)->void:
	super(_coord)

func inflict(cell: Vector2i, ctx: ActionContext)->void:
	if ctx.target.health.has(cell):
		ctx.target.damage_health_tile(cell)

func get_color()->Color:
	return Color("#ff7a7a")
