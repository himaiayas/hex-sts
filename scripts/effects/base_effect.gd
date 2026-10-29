@abstract class_name BaseEffect

extends Resource


var name: String
var description: String
## Turns left. Counts down at the end of the owner's turn; the effect is removed at 0.
## -1 = never runs out.
var turns := -1

func _init(_name: String, _description: String, _turns := -1) -> void:
	name = _name
	description = _description
	turns = _turns


## Called on every trigger of the owner; override and react to the ones you need.
## cell: the effect's own tile for tile effects. For powers it's the tile hit/blocked
## on ON_HIT/ON_BLOCK, and unused on turn triggers.
func on_trigger(_trigger: Enum.Trigger, _combat: CombatState, _unit: CombatUnit, _cell: Vector2i) -> void:
	pass


## Called at the end of the owner's turn. True when the effect has run out.
func tick() -> bool:
	if turns < 0:
		return false
	turns -= 1
	return turns <= 0


## A new instance with the same counter, so every tile/unit counts down on its own.
func copy() -> BaseEffect:
	var effect: BaseEffect = get_script().new()
	effect.turns = turns
	return effect


## Applying an effect the target already has adds the turns instead of a second copy.
func stack(other: BaseEffect) -> void:
	if turns >= 0 and other.turns >= 0:
		turns += other.turns
