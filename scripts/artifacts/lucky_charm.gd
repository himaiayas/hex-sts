class_name LuckyCharm
extends BaseArtifact


func _init() -> void:
	super("Lucky Charm", "Rare and Legendary cards and artifacts are twice as likely to show up.", Enum.ArtifactRarity.UNCOMMON)

const FACTOR := 2  # RunState.luck_factor
