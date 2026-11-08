class_name SpareHex
extends BaseArtifact


func _init() -> void:
	super("Spare Hex", "On pick up, place 2 new health tiles.", Enum.ArtifactRarity.COMMON)

func on_pickup() -> void:
	RunState.pending_tile_slots += 2
