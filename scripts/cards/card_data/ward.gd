class_name Ward
extends BaseCard


func _init() -> void:
	card_name = "Ward"
	cost = 2
	type = Enum.CardType.POWER
	target = Enum.TargetType.PLAYER
	description = "At the start of your turn, {keyword:Shield} 1 random tile."


func execute(combat: CombatState, units: Array[CombatUnit], cells: Array[Vector2i], rotations: Array[int])->Array:
	var hits: Array = await super(combat, units, cells, rotations)
	await ApplyPowerAction.new(Enum.TargetType.PLAYER, WardPower.new(1)).execute(combat, combat.player, Vector2i.ZERO)
	return hits
