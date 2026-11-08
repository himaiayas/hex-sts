class_name Unstoppable
extends BaseCard


func _init() -> void:
	card_name = "Unstoppable"
	cost = 3
	type = Enum.CardType.POWER
	rarity = Enum.CardRarity.RARE
	target = Enum.TargetType.PLAYER
	description = "At the start of your turn, gain 1 {keyword:Strength}."


func execute(combat: CombatState, units: Array[CombatUnit], cells: Array[Vector2i], rotations: Array[int])->Array:
	var hits: Array = await super(combat, units, cells, rotations)
	await ApplyPowerAction.new(Enum.TargetType.PLAYER, UnstoppablePower.new(1)).execute(combat, combat.player, Vector2i.ZERO)
	return hits
