class_name InfiniteWard
extends BaseCard


func _init() -> void:
	card_name = "InfiniteWard"
	cost = 1
	type = Enum.CardType.POWER
	rarity = Enum.CardRarity.RARE
	target = Enum.TargetType.PLAYER
	description = "At the start of your turn, apply 1 {keyword:Shield} to random tile."


func execute(combat: CombatState, units: Array[CombatUnit], cells: Array[Vector2i], rotations: Array[int])->Array:
	var hits: Array = await super(combat, units, cells, rotations)
	await ApplyPowerAction.new(Enum.TargetType.PLAYER, WardPower.new(1)).execute(combat, combat.player, Vector2i.ZERO)
	return hits
