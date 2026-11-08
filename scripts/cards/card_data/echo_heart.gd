class_name EchoHeart
extends BaseCard


func _init() -> void:
	card_name = "Echo Heart"
	cost = 1
	rarity = Enum.CardRarity.RARE
	type = Enum.CardType.SKILL
	target = Enum.TargetType.PLAYER
	description = "Your next Attack this turn is played twice."


func execute(combat: CombatState, units: Array[CombatUnit], cells: Array[Vector2i], rotations: Array[int])->Array:
	var hits: Array = await super(combat, units, cells, rotations)
	await ApplyPowerAction.new(Enum.TargetType.PLAYER, EchoPower.new(1)).execute(combat, combat.player, Vector2i.ZERO)
	return hits
