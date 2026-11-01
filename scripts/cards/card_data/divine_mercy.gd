class_name DivineMercy
extends BaseCard


func _init() -> void:
	card_name = "Divine Mercy"
	cost = 1
	type = Enum.CardType.SKILL
	target = Enum.TargetType.PLAYER
	description = "Gain 2 energy.\nDraw 1."


func execute(combat: CombatState, units: Array[CombatUnit], cells: Array[Vector2i], rotations: Array[int])->Array:
	var hits := super(combat, units, cells, rotations)
	GainEnergyAction.new(Enum.TargetType.PLAYER, 2).execute(combat, combat.player, Vector2i.ZERO)
	DrawAction.new(Enum.TargetType.PLAYER, 1).execute(combat, combat.player, Vector2i.ZERO)
	return hits
