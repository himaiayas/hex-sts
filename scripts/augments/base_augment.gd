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


## description without keyword tags, for tooltips and plain Labels.
func plain_description() -> String:
	return Keywords.markup(description)


## description as BBCode, keywords in KEYWORD_COLOR (augments sit on dark panels, like artifacts).
func bbcode_description() -> String:
	return Keywords.markup(description, "[color=#%s]" % KEYWORD_COLOR.to_html(false), "[/color]")


## HoverInfo entries for each keyword in the description: the same panels as hovering a card.
func keyword_entries() -> Array:
	var entries := []
	for keyword in Keywords.names_in(description):
		var text := Keywords.describe(keyword)
		if not text.is_empty():
			entries.append([keyword, text, null])
	return entries


const KEYWORD_COLOR := Color(1, 0.831373, 0.352941)


func can_apply(card: BaseCard) -> bool:
	return card.augments.size() < card.max_augments


## Tiles the player adds to the card's patterns in the AugmentModal before it's applied
## (ExpansionAugment.patterns has the patterns that can grow).
func tiles_to_add() -> int:
	return 0


## Changes the card, once, when the augment goes on it (after any tiles are added).
func apply(_card: BaseCard) -> void:
	pass
