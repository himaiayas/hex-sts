class_name ReservedArmoryPower
extends BasePower

## Whenever the player plays a Power card, moves amount random Attacks from the draw pile to the
## hand (while it has room); they cost 0 this turn. The Power card that applied it doesn't count.

var fresh := true  # just applied: the card that applied it is still being played


func _init(_amount := 1) -> void:
	super("Reserved Armory", "When you play a Power card, put 1 random Attack from your draw pile into your hand per Reserved Armory. It costs 0 this turn.", _amount)


func get_description() -> String:
	return "When you play a Power card, put %s from your draw pile into your hand. %s 0 this turn." % [
		plural(amount, "random Attack"), "It costs" if amount == 1 else "They cost"]


func on_card_played(combat: CombatState, _unit: CombatUnit, card: BaseCard) -> void:
	if fresh:
		fresh = false
		return
	if card.type != Enum.CardType.POWER:
		return
	for i in amount:
		var attacks := combat.draw_pile.filter(func(c: BaseCard) -> bool: return c.type == Enum.CardType.ATTACK)
		if attacks.is_empty() or combat.hand.size() >= CombatState.HAND_LIMIT:
			return
		var attack: BaseCard = attacks.pick_random()
		combat.draw_pile.erase(attack)
		attack.free_on_turn = combat.turn
		combat.hand.append(attack)


func get_color() -> Color:
	return Color("#a07850")
