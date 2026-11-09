class_name HallowedKnight
extends BaseCard


func _init() -> void:
	card_name = "Hallowed Knight"
	cost = 1
	type = Enum.CardType.POWER
	rarity = Enum.CardRarity.UNCOMMON
	target = Enum.TargetType.PLAYER
	description = "The first time you play an Attack costing 2 or more each turn, Cleanse 1 random tile."
	image = preload("res://assets/cards/cards/hallowed_knight.png")


func execute(combat: CombatState, units: Array[CombatUnit], cells: Array[Vector2i], rotations: Array[int])->Array:
	var hits: Array = await super(combat, units, cells, rotations)
	await ApplyPowerAction.new(Enum.TargetType.PLAYER, HallowedKnightPower.new(1)).execute(combat, combat.player, Vector2i.ZERO)
	return hits
