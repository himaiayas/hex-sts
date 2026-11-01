class_name RandomGridAction
extends GridAction

## Like RandomTileAction, but on one grid the player clicks: inflicts tiles[0] on amount
## random tiles of that grid. It has no pattern, so it can't be drawn with {render:N}.

var amount: int

func _init(_target: Enum.TargetType, _tile: BaseActionTile, _amount := 1)->void:
	super(_target, [_tile])
	amount = _amount

## cell and rotation are ignored: only which grid was clicked matters.
func execute(combat: CombatState, unit: CombatUnit, _cell: Vector2i, _rotation := 0)->Array[Vector2i]:
	var pool: Array[Vector2i] = []
	for cell in unit.health:
		if tiles[0].can_inflict(unit, cell):
			pool.append(cell)
	pool.shuffle()
	var hits: Array[Vector2i] = []
	var picks := pool.slice(0, amount)
	for cell in picks:
		if tiles[0].inflict(combat, unit, cell):
			hits.append(cell)
	if tiles[0] is DamageTile:
		hits.append_array(StrengthPower.spread(combat, picks.map(func(c: Vector2i) -> Array: return [unit, c])))
	return hits

## No pattern to preview; the grid view highlights the whole grid instead.
func rotated(_steps: int)->Dictionary[Vector2i, BaseActionTile]:
	return {}
