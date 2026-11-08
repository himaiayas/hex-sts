class_name SpikedGauntlet
extends BaseArtifact


func _init() -> void:
	super("Spiked Gauntlet", "Whenever you gain Retaliate, gain 1 more.", Enum.ArtifactRarity.UNCOMMON)

func modify_power(power: BaseEffect) -> void:
	if power is RetaliatePower:
		power.amount += 1
