class_name ReservedArmory
extends BaseCard


func _init() -> void:
	card_name = "Reserved Armory"
	cost = 2
	type = Enum.CardType.POWER
	rarity = Enum.CardRarity.UNCOMMON
	target = Enum.TargetType.PLAYER
	description = "When you play a Power card, put a random Attack from your draw pile into your hand. It costs 0 this turn."
	image = preload("res://assets/cards/cards/reserved_armory.png")


func execute(combat: CombatState, units: Array[CombatUnit], cells: Array[Vector2i], rotations: Array[int])->Array:
	var hits: Array = await super(combat, units, cells, rotations)
	await ApplyPowerAction.new(Enum.TargetType.PLAYER, ReservedArmoryPower.new(1)).execute(combat, combat.player, Vector2i.ZERO)
	return hits
