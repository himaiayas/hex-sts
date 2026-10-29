@abstract class_name BaseArtifact
extends Resource

## A relic the player keeps for the whole run (RunState.artifacts).
## Reacts to the player's triggers, like a power that never runs out.

var name: String
var description: String
var rarity: Enum.ArtifactRarity

func _init(_name: String, _description: String, _rarity: Enum.ArtifactRarity) -> void:
	name = _name
	description = _description
	rarity = _rarity


## unit is always the player. cell is the tile hit/blocked on ON_HIT/ON_BLOCK.
func on_trigger(_trigger: Enum.Trigger, _combat: CombatState, _unit: CombatUnit, _cell: Vector2i) -> void:
	pass
