class_name DragonScale
extends BaseArtifact


func _init() -> void:
	super("Dragon Scale", "On pick up, gain 1 Level.", Enum.ArtifactRarity.LEGENDARY,
		preload("res://assets/artifacts/dragon_scale.png"))

func on_pickup() -> void:
	if RunState.is_max_level():
		return
	RunState.level += 1
	RunState.pending_level_ups += 1
	RunState.add_xp(0)  # EXP past the new level's need rolls over
