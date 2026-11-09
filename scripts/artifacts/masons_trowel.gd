class_name MasonsTrowel
extends BaseArtifact


func _init() -> void:
	super("Mason's Trowel", "At the start of combat, choose 1 of 3 random Defense cards to add to your hand. It costs 0 until played.", Enum.ArtifactRarity.COMMON,
		preload("res://assets/artifacts/masons_trowel.png"))

const CHOICES := 3


func on_trigger(trigger: Enum.Trigger, combat: CombatState, _unit: CombatUnit, _cell: Vector2i) -> void:
	if trigger != Enum.Trigger.COMBAT_START:
		return
	var defenses: Array[BaseCard] = []
	for card_class in CardPool.CARDS:
		var card: BaseCard = card_class.new()
		if card.type == Enum.CardType.DEFENSE:
			defenses.append(card)
	defenses.shuffle()
	var offer: Array[BaseCard] = []
	offer.assign(defenses.slice(0, CHOICES))
	for card in await combat.choose_cards(offer, 1, "Mason's Trowel: choose a Defense card to add to your hand.", false):
		card.free_until_played = true
		combat.add_to_hand(card)
