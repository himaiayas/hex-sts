class_name ExpansionAugment
extends BaseAugment

## Adds 1 tile next to one of the card's patterns. The new tile copies the action of a tile
## next to it; if its neighbours do different things, the player picks one.
## Only for cards with a pattern (random grid actions have none).

const NEIGHBORS: Array[Vector2i] = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1),
	Vector2i(0, -1), Vector2i(1, -1), Vector2i(-1, 1)]


func _init() -> void:
	super("Expansion Augment",
		"Add 1 tile next to one of this card's patterns. It copies the action of a tile beside it.",
		preload("res://assets/augments/expansion.png"))
	price = 60


func can_apply(card: BaseCard) -> bool:
	return super(card) and not patterns(card).is_empty()


## The card's grid actions that have a pattern to grow.
static func patterns(card: BaseCard) -> Array[GridAction]:
	var result: Array[GridAction] = []
	for i in card.grid_actions.size():
		var action := card.pattern(i)
		if not action is RandomGridAction:
			result.append(action)
	return result


## Empty cells next to the pattern, in pattern space (tile coords + anchor).
static func free_cells(action: GridAction) -> Array[Vector2i]:
	var taken := {}
	for t in action.tiles:
		taken[t.coords + action.anchor] = true
	var result: Array[Vector2i] = []
	for cell: Vector2i in taken:
		for offset in NEIGHBORS:
			if not taken.has(cell + offset) and not result.has(cell + offset):
				result.append(cell + offset)
	return result


## What a new tile at cell can be: one copy per different action next to it.
static func tile_options(action: GridAction, cell: Vector2i) -> Array[BaseActionTile]:
	var seen := {}
	var result: Array[BaseActionTile] = []
	for t in action.tiles:
		if (t.coords + action.anchor - cell) in NEIGHBORS and not seen.has(t.kind()):
			seen[t.kind()] = true
			result.append(t.copy_at(cell - action.anchor))
	return result
