class_name Burnout
extends BaseCard

## A 7-tile flower that grows 1 tile per card exhausted this combat: around the 2nd ring first,
## starting at its right tile and going clockwise, then the 3rd ring the same way, and so on.

## Clockwise on screen, starting with the step from a ring's right tile toward its lower-right side.
const RING_STEPS: Array[Vector2i] = [Vector2i(-1, 1), Vector2i(-1, 0), Vector2i(0, -1),
	Vector2i(1, -1), Vector2i(1, 0), Vector2i(0, 1)]

var _base: GridAction  # the pattern before growing (an Expansion Augment's tiles included)


func _init() -> void:
	card_name = "Burnout"
	cost = 2
	type = Enum.CardType.ATTACK
	rarity = Enum.CardRarity.UNCOMMON
	description = "{render:0}\nGrows by 1 tile for each card you {keyword:Exhaust} this combat."
	grid_actions = [
		GridAction.new(Enum.TargetType.ENEMY, [
			DamageTile.new(Vector2i(0,0)),
			DamageTile.new(Vector2i(1,0)),
			DamageTile.new(Vector2i(0,1)),
			DamageTile.new(Vector2i(-1,1)),
			DamageTile.new(Vector2i(-1,0)),
			DamageTile.new(Vector2i(0,-1)),
			DamageTile.new(Vector2i(1,-1)),
		]),
	]


## Rebuilds the pattern as the base plus one ring tile per exhausted card. The base GridAction
## is never changed, since the deck's copy of this card may share it.
func on_card_exhausted(combat: CombatState) -> void:
	if _base == null:
		_base = pattern(0)
	var tiles: Array[BaseActionTile] = _base.tiles.duplicate()
	var taken: Array[Vector2i] = []
	for tile in tiles:
		taken.append(tile.coords)
	var grow := combat.exhausted_this_combat
	var radius := 2
	while grow > 0:
		for cell in _ring(radius):
			if grow == 0:
				break
			if cell not in taken:
				tiles.append(DamageTile.new(cell))
				grow -= 1
		radius += 1
	grid_actions = [GridAction.new(_base.target, tiles, _base.anchor, _base.must_land)]
	emit_changed()


## The cells at distance radius from the centre, from the right one, clockwise.
static func _ring(radius: int) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	var cell := Vector2i(radius, 0)
	for step in RING_STEPS:
		for i in radius:
			cells.append(cell)
			cell += step
	return cells
