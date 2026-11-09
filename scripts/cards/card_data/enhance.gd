class_name Enhance
extends BaseCard


func _init() -> void:
	card_name = "Enhance"
	cost = 1
	type = Enum.CardType.POWER
	target = Enum.TargetType.PLAYER
	description = "Gain 1 {keyword:Strength}."
	image = preload("res://assets/cards/cards/enhance.png")


func execute(combat: CombatState, units: Array[CombatUnit], cells: Array[Vector2i], rotations: Array[int])->Array:
	var hits: Array = await super(combat, units, cells, rotations)
	await ApplyPowerAction.new(Enum.TargetType.PLAYER, StrengthPower.new(1)).execute(combat, combat.player, Vector2i.ZERO)
	return hits
