class_name WellPrepared
extends BaseCard


func _init() -> void:
	card_name = "Well Prepared"
	cost = 2
	type = Enum.CardType.POWER
	rarity = Enum.CardRarity.UNCOMMON
	target = Enum.TargetType.PLAYER
	description = "At the start of your turn, draw 1 more card."


func execute(combat: CombatState, units: Array[CombatUnit], cells: Array[Vector2i], rotations: Array[int])->Array:
	var hits: Array = await super(combat, units, cells, rotations)
	await ApplyPowerAction.new(Enum.TargetType.PLAYER, ForesightPower.new(1)).execute(combat, combat.player, Vector2i.ZERO)
	return hits
