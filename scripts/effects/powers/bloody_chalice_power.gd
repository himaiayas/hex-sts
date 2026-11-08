class_name BloodyChalicePower
extends BasePower

## The first time one of the owner's tiles is damaged during their own turn (Sacrifice, Fracture,
## Poison...), they gain amount energy. Once per turn.

var used := false  # already triggered this turn


func _init(_amount := 1) -> void:
	super("Bloody Chalice", "The first time you lose a health tile during your turn, gain 1 Energy per Bloody Chalice.", _amount)


func get_description() -> String:
	return "The first time you lose a health tile during your turn, gain %d Energy.%s" % [
		amount, " (Used this turn.)" if used else ""]


func on_trigger(trigger: Enum.Trigger, combat: CombatState, unit: CombatUnit, _cell: Vector2i) -> void:
	match trigger:
		Enum.Trigger.TURN_START:
			used = false
		Enum.Trigger.ON_HIT:
			if unit.in_turn and not used:
				used = true
				combat.energy += amount


func get_color() -> Color:
	return Color("#8e1b2e")
