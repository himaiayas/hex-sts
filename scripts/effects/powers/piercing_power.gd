class_name PiercingPower
extends BasePower

## Chronokinesis: during the owner's next turn, every hit of their Attack cards pierces Shield.
## Applied waiting; it starts at the owner's next turn start and is removed at that turn's end.

var waiting := true  # not active yet: applied this turn, works from the next one


func _init() -> void:
	super("Piercing", "Next turn, your Attacks deal Piercing damage.")
	show_amount = false


func get_description() -> String:
	return "%s, your Attacks deal Piercing damage." % ("Next turn" if waiting else "This turn")


func on_trigger(trigger: Enum.Trigger, _combat: CombatState, unit: CombatUnit, _cell: Vector2i) -> void:
	match trigger:
		Enum.Trigger.TURN_START:
			waiting = false
		Enum.Trigger.TURN_END:
			if not waiting:
				unit.statuses.erase(self)


## Whether a hit on target pierces now: the player is playing an Attack card with an active Piercing.
static func active(combat: CombatState, target: CombatUnit) -> bool:
	if target.is_player or combat.playing == null or combat.playing.type != Enum.CardType.ATTACK:
		return false
	for power in combat.player.statuses:
		if power is PiercingPower and not power.waiting:
			return true
	return false


func get_color() -> Color:
	return Color("#c46bff")
