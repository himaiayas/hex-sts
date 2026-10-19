class_name ShieldTile
extends BaseActionTile


func _init(_coord: Vector2i)->void:
	super(_coord)

func inflict(cell: Vector2i, ctx: ActionContext)->void:
	if ctx.target.health.has(cell) and ctx.target.health[cell].hp != HealthTile.HealthTileEnum.DAMAGED:
		ctx.target.shield_health_tile(cell)

func get_color()->Color:
	return Color("#a0e5f6")