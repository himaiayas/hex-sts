class_name OblationPower
extends BasePower

## Whenever a card is exhausted, the player draws amount cards.


func _init(_amount := 1) -> void:
	super("Oblation", "Whenever a card is Exhausted, draw 1 card per Oblation.", _amount)


func get_description() -> String:
	return "Whenever a card is Exhausted, draw %s." % plural(amount, "card")


func on_card_exhausted(combat: CombatState, _unit: CombatUnit, _card: BaseCard) -> void:
	combat.draw(amount)


func get_color() -> Color:
	return Color("#c0392b")
