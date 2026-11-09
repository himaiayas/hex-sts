class_name RevivalChant
extends BaseCard


func _init() -> void:
	card_name = "Revival Chant"
	cost = 1
	type = Enum.CardType.POWER
	rarity = Enum.CardRarity.UNCOMMON
	target = Enum.TargetType.PLAYER
	description = "At the start of your turn, put 1 random card from your discard pile into your hand."
	image = preload("res://assets/cards/cards/revival_chant.png")


func execute(combat: CombatState, units: Array[CombatUnit], cells: Array[Vector2i], rotations: Array[int])->Array:
	var hits: Array = await super(combat, units, cells, rotations)
	await ApplyPowerAction.new(Enum.TargetType.PLAYER, RevivalChantPower.new(1)).execute(combat, combat.player, Vector2i.ZERO)
	return hits
