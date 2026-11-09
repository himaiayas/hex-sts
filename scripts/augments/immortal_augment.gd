class_name ImmortalAugment
extends BaseAugment

## The card loses Exhaust. Only for cards that Exhaust.


func _init() -> void:
	super("Immortal Augment", "Remove {keyword:Exhaust} from this card.",
		preload("res://assets/augments/immortal.png"))  # placeholder icon
	price = 70


func can_apply(card: BaseCard) -> bool:
	return super(card) and card.exhaust


func apply(card: BaseCard) -> void:
	card.exhaust = false
