class_name DivineMercy
extends BaseCard


func _init() -> void:
	card_name = "Divine Mercy"
	cost = 1
	type = Enum.CardType.SKILL
	target = Enum.TargetType.PLAYER
	exhaust = true
	description = "Gain 1 energy. Draw 2 cards.\n{keyword:Exhaust}."
	image = preload("res://assets/cards/cards/divine_mercy.png")


func execute(combat: CombatState, units: Array[CombatUnit], cells: Array[Vector2i], rotations: Array[int])->Array:
	var hits: Array = await super(combat, units, cells, rotations)
	GainEnergyAction.new(Enum.TargetType.PLAYER, 1).execute(combat, combat.player, Vector2i.ZERO)
	DrawAction.new(Enum.TargetType.PLAYER, 2).execute(combat, combat.player, Vector2i.ZERO)
	return hits
