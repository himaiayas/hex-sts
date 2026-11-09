class_name BastionBrick
extends BaseArtifact


func _init() -> void:
	super("Bastion Brick", "On pick up, place 4 new health tiles.", Enum.ArtifactRarity.UNCOMMON,
		preload("res://assets/artifacts/bastion_brick.png"))

func on_pickup() -> void:
	RunState.pending_tile_slots += 4
