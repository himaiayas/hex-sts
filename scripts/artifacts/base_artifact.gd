@abstract class_name BaseArtifact
extends Resource

## A relic the player keeps for the whole run (RunState.artifacts).
## Reacts to the player's triggers, like a power that never runs out.

var name: String
var description: String
var rarity: Enum.ArtifactRarity
var image: Texture2D  # shown wherever the artifact is (256x256)

const PLACEHOLDER_IMAGE := preload("res://assets/artifacts/placeholder.png")

func _init(_name: String, _description: String, _rarity: Enum.ArtifactRarity,
		_image: Texture2D = PLACEHOLDER_IMAGE) -> void:
	name = _name
	description = _description
	rarity = _rarity
	image = _image


## unit is always the player. cell is the tile hit/blocked on ON_HIT/ON_BLOCK.
func on_trigger(_trigger: Enum.Trigger, _combat: CombatState, _unit: CombatUnit, _cell: Vector2i) -> void:
	pass
