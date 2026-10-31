class_name Enhance
extends BaseCard


func _init() -> void:
	card_name = "Enhance"
	cost = 1
	type = Enum.CardType.POWER
	target = Enum.TargetType.PLAYER
	description = "Gain 1 {keyword:Strength}."


func execute(combat: CombatState, units: Array[CombatUnit], cells: Array[Vector2i], rotations: Array[int])->Array:
	var hits := super(combat, units, cells, rotations)
	ApplyPowerAction.new(Enum.TargetType.PLAYER, StrengthPower.new(1)).execute(combat, combat.player, Vector2i.ZERO)
	return hits
