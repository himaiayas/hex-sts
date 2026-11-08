class_name Duelist
extends BaseCard


func _init() -> void:
	card_name = "Duelist"
	cost = 1
	type = Enum.CardType.POWER
	rarity = Enum.CardRarity.UNCOMMON
	target = Enum.TargetType.PLAYER
	description = "Every time you play 3 Attacks in a single turn, apply {keyword:Shield} to 1 random tile."
	image = preload("res://assets/cards/cards/duelist.png")


func execute(combat: CombatState, units: Array[CombatUnit], cells: Array[Vector2i], rotations: Array[int])->Array:
	var hits: Array = await super(combat, units, cells, rotations)
	await ApplyPowerAction.new(Enum.TargetType.PLAYER, DuelistPower.new(1)).execute(combat, combat.player, Vector2i.ZERO)
	return hits
