class_name Aegis
extends BaseCard


func _init() -> void:
	card_name = "Aegis"
	cost = 1
	type = Enum.CardType.DEFENSE
	target = Enum.TargetType.PLAYER
	rarity = Enum.CardRarity.LEGENDARY
	exhaust = true
	description = "{render:0}\nAll tiles with Shield gain Plate. {keyword:Exhaust}."
	grid_actions = [
		GridAction.new(Enum.TargetType.PLAYER, [
			ShieldTile.new(Vector2i(0,0)),
			ShieldTile.new(Vector2i(1,0)),
			ShieldTile.new(Vector2i(0,1)),
			ShieldTile.new(Vector2i(-1,1)),
			ShieldTile.new(Vector2i(-1,0)),
			ShieldTile.new(Vector2i(1,-1)),
			ShieldTile.new(Vector2i(0,-1)),
		]),
	]


## After the shields go up: every shielded tile without Plate gets it.
func execute(combat: CombatState, units: Array[CombatUnit], cells: Array[Vector2i], rotations: Array[int])->Array:
	var hits: Array = await super(combat, units, cells, rotations)
	var player := combat.player
	for cell: Vector2i in player.health:
		var tile: HealthTile = player.health[cell]
		if tile.hp == Enum.HealthTileEnum.SHIELDED and not tile.has_effect(PlateTileEffect):
			player.apply_effect_health_tile(combat, cell, PlateTileEffect.new())
	await combat.flush()
	return hits
