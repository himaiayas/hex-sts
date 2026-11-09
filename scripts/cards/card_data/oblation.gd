class_name Oblation
extends BaseCard


func _init() -> void:
	card_name = "Oblation"
	cost = 2
	type = Enum.CardType.POWER
	rarity = Enum.CardRarity.RARE
	target = Enum.TargetType.PLAYER
	description = "Whenever a card is {keyword:Exhaust|Exhausted}, draw 1 card."
	image = preload("res://assets/cards/cards/oblation.png")


func execute(combat: CombatState, units: Array[CombatUnit], cells: Array[Vector2i], rotations: Array[int])->Array:
	var hits: Array = await super(combat, units, cells, rotations)
	await ApplyPowerAction.new(Enum.TargetType.PLAYER, OblationPower.new(1)).execute(combat, combat.player, Vector2i.ZERO)
	return hits
