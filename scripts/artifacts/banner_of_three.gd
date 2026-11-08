class_name BannerOfThree
extends BaseArtifact


func _init() -> void:
	super("Banner of Three", "Each turn, if the third card you play is a Defense, Shield 1 random tile.", Enum.ArtifactRarity.UNCOMMON,
		preload("res://assets/artifacts/banner_of_three.png"))

func on_card_played(combat: CombatState, card: BaseCard) -> void:
	if combat.played_this_turn.size() != 3 or combat.played_this_turn[2] != card or card.type != Enum.CardType.DEFENSE:
		return
	var open := func(t: HealthTile) -> bool: return t.hp == Enum.HealthTileEnum.UNDAMAGED
	for cell in player_cells(combat, open).slice(0, 1):
		combat.player.shield_health_tile(combat, cell)
