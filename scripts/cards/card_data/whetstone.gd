class_name Whetstone
extends BaseCard


func _init() -> void:
	card_name = "Whetstone"
	cost = 1
	type = Enum.CardType.SKILL
	target = Enum.TargetType.PLAYER
	description = "Gain 2 {keyword:Strength} this turn."
	image = preload("res://assets/cards/cards/whetstone.png")


func execute(combat: CombatState, units: Array[CombatUnit], cells: Array[Vector2i], rotations: Array[int])->Array:
	var hits: Array = await super(combat, units, cells, rotations)
	await ApplyPowerAction.new(Enum.TargetType.PLAYER, StrengthPower.new(2, true)).execute(combat, combat.player, Vector2i.ZERO)
	return hits
