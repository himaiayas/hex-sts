class_name DuplicationAugment
extends BaseAugment

## The card costs 1 more and gains Repeat: its effect runs twice each time it's played.
## Not for X-cost cards, Powers, or cards that already Repeat.


func _init() -> void:
	super("Repetition Augment", "Increase this card's cost by 1. It gains {keyword:Repeat}.",
		preload("res://assets/augments/repetition.png"))  # placeholder icon
	price = 80


func can_apply(card: BaseCard) -> bool:
	return super(card) and not card.x_cost and not card.repeat and card.type != Enum.CardType.POWER


func apply(card: BaseCard) -> void:
	card.cost += 1
	card.repeat = true
