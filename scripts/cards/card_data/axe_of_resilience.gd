class_name AxeOfResilience
extends BaseCard


func _init() -> void:
	card_name = "Axe of Resilience"
	cost = 2
	type = Enum.CardType.ATTACK
	rarity = Enum.CardRarity.UNCOMMON
	description = "{render:0}\nDeal damage to 1 random enemy tile per {keyword:Plate|Plated} tile you have."
	image = preload("res://assets/cards/cards/axe_of_resillience.png")

	grid_actions = [
		GridAction.new(Enum.TargetType.ENEMY, [
			DamageTile.new(Vector2i(0,0)),
			DamageTile.new(Vector2i(-1,0)),
			DamageTile.new(Vector2i(-2,0)),
			DamageTile.new(Vector2i(-3,0)),
			DamageTile.new(Vector2i(-4,0)),
			DamageTile.new(Vector2i(0,1)),
			DamageTile.new(Vector2i(-1,1)),
			DamageTile.new(Vector2i(0,2)),
			DamageTile.new(Vector2i(-1,2)),
			DamageTile.new(Vector2i(-2,2)),
		]),
	]


## After the pattern: one random enemy tile per Plated tile on the player's grid.
func execute(combat: CombatState, units: Array[CombatUnit], cells: Array[Vector2i], rotations: Array[int])->Array:
	var hits: Array = await super(combat, units, cells, rotations)
	var plated := combat.player.health.values().filter(
		func(tile: HealthTile) -> bool: return tile.has_effect(PlateTileEffect)).size()
	if plated > 0:
		await RandomTileAction.new(Enum.TargetType.ENEMY, DamageTile.new(Vector2i.ZERO), plated).execute(combat, combat.player, Vector2i.ZERO)
	return hits
