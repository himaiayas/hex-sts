class_name RevivalChantPower
extends BasePower

## At the start of its owner's turn (before the draw), moves amount random cards from the discard
## pile to the hand, while the hand has room.


func _init(_amount := 1) -> void:
	super("Revival Chant", "At the start of your turn, put 1 random card from your discard pile into your hand per Revival Chant.", _amount)


func get_description() -> String:
	return "At the start of your turn, put %s from your discard pile into your hand." % plural(amount, "random card")


func on_trigger(trigger: Enum.Trigger, combat: CombatState, _unit: CombatUnit, _cell: Vector2i) -> void:
	if trigger != Enum.Trigger.TURN_START:
		return
	for i in amount:
		if combat.discard_pile.is_empty() or combat.hand.size() >= CombatState.HAND_LIMIT:
			return
		var card: BaseCard = combat.discard_pile.pick_random()
		combat.discard_pile.erase(card)
		combat.hand.append(card)


func get_color() -> Color:
	return Color("#9be37a")
