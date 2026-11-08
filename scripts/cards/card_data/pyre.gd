class_name Pyre
extends BaseCard


func _init() -> void:
	card_name = "Pyre"
	cost = 1
	type = Enum.CardType.SKILL
	rarity = Enum.CardRarity.COMMON
	target = Enum.TargetType.PLAYER
	description = "{keyword:Exhaust} all non-Attack cards in your hand. Draw that many cards."


func execute(combat: CombatState, units: Array[CombatUnit], cells: Array[Vector2i], rotations: Array[int])->Array:
	var hits: Array = await super(combat, units, cells, rotations)
	var exhausted_card := 0
	for card: BaseCard in combat.hand.duplicate():
		if card.type != Enum.CardType.ATTACK:
			combat.exhaust(card)
			exhausted_card += 1
	DrawAction.new(Enum.TargetType.PLAYER, exhausted_card).execute(combat, combat.player, Vector2i.ZERO)
	return hits
