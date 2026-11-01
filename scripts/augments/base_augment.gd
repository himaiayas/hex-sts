@abstract class_name BaseAugment
extends Resource

## An upgrade put on one card in the deck, like an enchantment. Getting one means applying it
## to a card right away (AugmentModal). A card holds up to BaseCard.max_augments augments.

var name: String
var description: String
var icon: Texture2D  # shown at the top center of the card
var price := 50 


func _init(_name: String, _description: String, _icon: Texture2D) -> void:
	name = _name
	description = _description
	icon = _icon


func can_apply(card: BaseCard) -> bool:
	return card.augments.size() < card.max_augments
