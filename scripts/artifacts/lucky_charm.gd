class_name LuckyCharm
extends BaseArtifact


const ARTIFACT_MULTIPLIERS := {
	Enum.ArtifactRarity.RARE: 2.0,
	Enum.ArtifactRarity.LEGENDARY: 2.0,
}
const CARD_MULTIPLIERS := {
	Enum.CardRarity.RARE: 2.0,
	Enum.CardRarity.LEGENDARY: 2.0,
}


func _init() -> void:
	super("Lucky Charm", "You are more lucky :D", Enum.ArtifactRarity.UNCOMMON,
		preload("res://assets/artifacts/lucky_charm.png"))
