class_name SpikedGauntlet
extends BaseArtifact


func _init() -> void:
	super("Spiked Gauntlet", "Whenever you gain {keyword:Retaliate}, gain 1 more.", Enum.ArtifactRarity.UNCOMMON,
		preload("res://assets/artifacts/spiked_gauntlet.png"))

func modify_power(power: BaseEffect) -> void:
	if power is RetaliatePower:
		power.amount += 1
