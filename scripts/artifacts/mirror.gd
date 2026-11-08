class_name Mirror
extends BaseArtifact


func _init() -> void:
	super("Mirror", "You can flip card patterns: press F while placing one.", Enum.ArtifactRarity.COMMON,
		preload("res://assets/artifacts/mirror.png"))

## The flip itself is in the combat scene (KEY_F) and GridAction.rotated (steps 6-11).
