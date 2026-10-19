class_name StatusTile
extends BaseActionTile


var status: BaseStatus  
func _init(_coords: Vector2i, _status: BaseStatus)->void:
	super(_coords)
	status = _status

func inflict(cell: Vector2i, ctx: ActionContext)->void:
	if ctx.target.health.has(cell):
		ctx.target.apply_status_health_tile(cell, status)

func get_color()->Color:
	return status.get_color()
