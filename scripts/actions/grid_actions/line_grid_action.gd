class_name LineGridAction
extends GridAction

## Inflicts one tile on every cell of the straight line through the clicked cell, across the whole grid.
## Rotating turns the line; three steps bring it back. tiles is only a short line for {render:N}.

const REACH := 12  # cells each way from the clicked one, past the edge of any grid
const SHOWN := 2  # cells drawn on the card each way from the middle


func _init(_target: Enum.TargetType, _tile: BaseActionTile)->void:
	var shown: Array[BaseActionTile] = []
	for q in range(-SHOWN, SHOWN + 1):
		shown.append(_tile.copy_at(Vector2i(q, 0)))
	super(_target, shown)

func rotated(steps: int)->Dictionary[Vector2i, BaseActionTile]:
	var dir := orient(Vector2i(1, 0), steps)
	var pattern: Dictionary[Vector2i, BaseActionTile] = {}
	for k in range(-REACH, REACH + 1):
		pattern[dir * k] = tiles[0]
	return pattern
