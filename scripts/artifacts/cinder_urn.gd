class_name CinderUrn
extends BaseArtifact


func _init() -> void:
	super("Cinder Urn", "Whenever a card is Exhausted, deal damage to 1 random enemy tile.", Enum.ArtifactRarity.UNCOMMON,
		preload("res://assets/artifacts/cinder_urn.png"))

func on_card_exhausted(combat: CombatState, _card: BaseCard) -> void:
	for pick in enemy_cells(combat, undamaged).slice(0, 1):
		pick[0].damage_health_tile(combat, pick[1])
