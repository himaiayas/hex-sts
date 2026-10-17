@abstract class_name BaseActionTile
extends Resource

var coords:Vector2i

func _init(_coords:Vector2i)->void:
	self.coords=_coords

@abstract
func inflict(cell: Vector2i, ctx: ActionContext)->void
