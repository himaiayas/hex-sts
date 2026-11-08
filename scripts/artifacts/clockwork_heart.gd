class_name ClockworkHeart
extends BaseArtifact


func _init() -> void:
	super("Clockwork Heart", "Every 10th Attack you play gives 1 Energy.", Enum.ArtifactRarity.RARE)

const EVERY := 10

var attacks := 0  # Attacks played since it was picked up, across combats


func on_card_played(combat: CombatState, card: BaseCard) -> void:
	if card.type != Enum.CardType.ATTACK:
		return
	attacks += 1
	if attacks % EVERY == 0:
		combat.energy += 1
	description = "Every 10th Attack you play gives 1 Energy. (%d/%d)" % [attacks % EVERY, EVERY]
