class_name PowerfulAugment
extends BaseAugment

## Like Expansion Augment twice (the player adds 2 tiles), but the card gains Exhaust.
## Only for cards with a pattern that don't already Exhaust.


func _init() -> void:
	super("Powerful Augment", "Add 2 tiles to this card's patterns. It gains {keyword:Exhaust}.",
		preload("res://assets/augments/powerful.png"))  # placeholder icon
	price = 70


func can_apply(card: BaseCard) -> bool:
	return super(card) and not card.exhaust and not ExpansionAugment.patterns(card).is_empty()


func tiles_to_add() -> int:
	return 2


func apply(card: BaseCard) -> void:
	card.exhaust = true
