class_name EmberPouch
extends BaseArtifact


func _init() -> void:
	super("Ember Pouch", "The first time a card is {keyword:Exhaust}ed each combat, draw 2 cards.", Enum.ArtifactRarity.COMMON,
		preload("res://assets/artifacts/ember_pouch.png"))

func on_card_exhausted(combat: CombatState, _card: BaseCard) -> void:
	if combat.exhausted_this_combat == 1:
		combat.draw(2)
