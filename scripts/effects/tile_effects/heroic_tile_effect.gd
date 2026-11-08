class_name HeroicTileEffect
extends BaseTileEffect

## Gives its owner 1 Strength while every tile next to it on the grid is damaged.
## Checked each time the Strength is used (StrengthPower.spread), so it switches on and off by itself.

const DIRS: Array[Vector2i] = [
	Vector2i(1, 0), Vector2i(1, -1), Vector2i(0, -1),
	Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, 1),
]


func _init() -> void:
	super("Heroic", "While every tile next to this one is damaged, gives 1 Strength.")


func get_color() -> Color:
	return Color("#ffd24a")


## Strength unit gets from its Heroic tiles right now: 1 per tile whose neighbours are all damaged.
static func strength(unit: CombatUnit) -> int:
	var total := 0
	for cell: Vector2i in unit.health:
		if unit.health[cell].has_effect(HeroicTileEffect) and _surrounded(unit, cell):
			total += 1
	return total


## Every neighbour on the grid is damaged (cells off the grid don't count).
static func _surrounded(unit: CombatUnit, cell: Vector2i) -> bool:
	for dir in DIRS:
		var next := cell + dir
		if unit.health.has(next) and unit.health[next].hp != Enum.HealthTileEnum.DAMAGED:
			return false
	return true
