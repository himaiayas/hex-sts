class_name RandomTileAction
extends BaseAction

## Inflicts tile on amount random tiles, picked from one pool: the player's tiles (PLAYER),
## or the tiles of every living enemy (ENEMY), so an enemy with more tiles left is hit more often.
## The same tile is never picked twice, and only tiles tile.can_inflict() can be picked.

var tile: BaseActionTile
var amount: int

func _init(_target: Enum.TargetType, _tile: BaseActionTile, _amount := 1)->void:
	super(_target)
	tile = _tile
	amount = _amount

## unit and cell are ignored: the targets come from target.
func execute(combat: CombatState, _unit: CombatUnit, _cell: Vector2i)->Array[Vector2i]:
	var units: Array[CombatUnit] = [combat.player]
	if target == Enum.TargetType.ENEMY:
		units = combat.enemies.filter(func(e: CombatUnit) -> bool: return not e.is_dead())
	var pool := []  # [unit, cell]
	for unit in units:
		for cell in unit.health:
			if tile.can_inflict(unit, cell):
				pool.append([unit, cell])
	pool.shuffle()
	var hits: Array[Vector2i] = []
	var picks := pool.slice(0, amount)
	for pick in picks:
		if tile.inflict(combat, pick[0], pick[1]):
			hits.append(pick[1])
	if tile is DamageTile:
		hits.append_array(StrengthPower.spread(combat, picks))
	return hits
