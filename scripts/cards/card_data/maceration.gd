class_name Maceration
extends BaseCard

const DIRS: Array[Vector2i] = [
	Vector2i(1, 0), Vector2i(1, -1), Vector2i(0, -1),
	Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, 1),
]


func _init() -> void:
	card_name = "Maceration"
	cost = 1
	type = Enum.CardType.SKILL
	rarity = Enum.CardRarity.RARE
	description = "Apply {keyword:Fracture} to every tile next to a Fractured tile on each enemy."


## Spreads from the tiles fractured when it's played, so new Fracture doesn't spread again.
func execute(combat: CombatState, units: Array[CombatUnit], cells: Array[Vector2i], rotations: Array[int])->Array:
	var hits: Array = await super(combat, units, cells, rotations)
	for enemy in combat.enemies:
		if enemy.is_dead():
			continue
		var fractured: Array[Vector2i] = []
		for cell: Vector2i in enemy.health:
			if enemy.health[cell].has_effect(FractureTileEffect):
				fractured.append(cell)
		var targets: Array[Vector2i] = []
		for cell in fractured:
			for dir in DIRS:
				var next := cell + dir
				if enemy.health.has(next) and next not in fractured and next not in targets \
						and enemy.health[next].hp != Enum.HealthTileEnum.DAMAGED:
					targets.append(next)
		for cell in targets:
			enemy.apply_effect_health_tile(combat, cell, FractureTileEffect.new())
	await combat.flush()
	return hits
