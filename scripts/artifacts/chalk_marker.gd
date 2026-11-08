class_name ChalkMarker
extends BaseArtifact


func _init() -> void:
	super("Chalk Marker", "At the end of your turn, you may choose 1 card to keep in your hand.", Enum.ArtifactRarity.UNCOMMON)

func before_discard(combat: CombatState) -> void:
	var cards: Array[BaseCard] = []
	cards.assign(combat.hand.filter(func(c: BaseCard) -> bool: return not c.retain))
	if cards.is_empty():
		return
	var picked := await combat.choose_cards(cards, 1, "Chalk Marker: choose up to 1 card to keep in your hand.", true, 0)
	combat.retained_once.append_array(picked)
