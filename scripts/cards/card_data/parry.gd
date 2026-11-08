class_name Parry
extends BaseCard


func _init() -> void:
	card_name = "Parry"
	cost = 0
	type = Enum.CardType.SKILL
	target = Enum.TargetType.PLAYER
	rarity = Enum.CardRarity.UNCOMMON
	retain = true
	description = "Gain 1 {keyword:Retaliate} this turn. {keyword:Retain}."
	image = preload("res://assets/cards/cards/parry.png")


func execute(combat: CombatState, units: Array[CombatUnit], cells: Array[Vector2i], rotations: Array[int])->Array:
	var hits: Array = await super(combat, units, cells, rotations)
	await ApplyPowerAction.new(Enum.TargetType.PLAYER, RetaliatePower.new(1)).execute(combat, combat.player, Vector2i.ZERO)
	return hits
