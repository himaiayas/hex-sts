class_name DeepBreath
extends BaseCard


func _init() -> void:
	card_name = "Deep Breath"
	cost = 0
	type = Enum.CardType.SKILL
	target = Enum.TargetType.PLAYER
	description = "Draw 2 cards. Discard 1 card. {keyword:Exhaust}."
	image = preload("res://assets/cards/cards/deep_breath.png")
	exhaust= true


func execute(combat: CombatState, units: Array[CombatUnit], cells: Array[Vector2i], rotations: Array[int])->Array:
	var hits: Array = await super(combat, units, cells, rotations)
	DrawAction.new(Enum.TargetType.PLAYER, 2).execute(combat, combat.player, Vector2i.ZERO)
	await DiscardFromHandAction.new(1).execute(combat, combat.player, Vector2i.ZERO)
	return hits
