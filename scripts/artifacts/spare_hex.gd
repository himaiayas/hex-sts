class_name SpareHex
extends BaseArtifact


func _init() -> void:
	super("Spare Hex", "On pick up, place 2 new health tiles.", Enum.ArtifactRarity.COMMON,
		preload("res://assets/artifacts/spare_hex.png"))

func on_pickup() -> void:
	RunState.pending_tile_slots += 2
