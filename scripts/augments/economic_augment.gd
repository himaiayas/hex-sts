class_name EconomicAugment
extends BaseAugment

## The card costs 1 less. Not for cards that already cost 0 or cost X.


func _init() -> void:
	super("Economic Augment", "Reduce this card's cost by 1.",
		preload("res://assets/augments/economic.png"))  # placeholder icon
	price = 60


func can_apply(card: BaseCard) -> bool:
	return super(card) and not card.x_cost and card.cost > 0


func apply(card: BaseCard) -> void:
	card.cost -= 1
