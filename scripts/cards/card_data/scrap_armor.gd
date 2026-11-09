class_name ScrapArmor
extends BaseCard


func _init() -> void:
	card_name = "Scrap Armor"
	cost = 1
	type = Enum.CardType.DEFENSE
	rarity = Enum.CardRarity.UNCOMMON
	target = Enum.TargetType.PLAYER
	description = "{keyword:Exhaust} 1 card in your hand.\n{render:0}."
	image = preload("res://assets/cards/cards/scrap_armor.png")
	grid_actions = [
        GridAction.new(Enum.TargetType.PLAYER, [
			ShieldTile.new(Vector2i(0,0)),
			ShieldTile.new(Vector2i(1,0)),
			ShieldTile.new(Vector2i(0,1)),
			
        ]),
    ]


func execute(combat: CombatState, units: Array[CombatUnit], cells: Array[Vector2i], rotations: Array[int])->Array:
	await ExhaustFromHandAction.new(1).execute(combat, combat.player, Vector2i.ZERO)
	var hits: Array = await super(combat, units, cells, rotations)
	return hits
