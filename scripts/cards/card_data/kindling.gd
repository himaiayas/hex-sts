class_name Kindling
extends BaseCard


func _init() -> void:
	card_name = "Kindling"
	cost = 1
	type = Enum.CardType.SKILL
	target = Enum.TargetType.PLAYER
	description = "{keyword:Exhaust} 1 card in your hand.\nDraw 2."


func execute(combat: CombatState, units: Array[CombatUnit], cells: Array[Vector2i], rotations: Array[int])->Array:
	var hits: Array = await super(combat, units, cells, rotations)
	await ExhaustFromHandAction.new(1).execute(combat, combat.player, Vector2i.ZERO)
	DrawAction.new(Enum.TargetType.PLAYER, 2).execute(combat, combat.player, Vector2i.ZERO)
	return hits
