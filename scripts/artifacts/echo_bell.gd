class_name EchoBell
extends BaseArtifact


func _init() -> void:
	super("Echo Bell", "Each turn, your second Attack is played twice.", Enum.ArtifactRarity.RARE)

func extra_plays(combat: CombatState, card: BaseCard) -> int:
	if card.type != Enum.CardType.ATTACK:
		return 0
	var attacks := combat.played_this_turn.filter(func(c: BaseCard) -> bool: return c.type == Enum.CardType.ATTACK)
	return 1 if attacks.size() == 2 and attacks[1] == card else 0
