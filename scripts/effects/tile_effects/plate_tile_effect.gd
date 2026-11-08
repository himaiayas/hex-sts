class_name PlateTileEffect
extends BaseTileEffect

## Not implemented yet (sheet draft only): the 20-hex cap. Smash, Shred and Corrode use strip().

var attacked := false  # hit during the opponent's turn, so no Shield next turn


func _init() -> void:
	super("Plate", "At the start of its owner's turn, shields the tile unless it was attacked during the opponent's turn. Removed when the tile is damaged.")
	order = 1  # after Poison, so Plate alone doesn't make a tile immune


func on_trigger(trigger: Enum.Trigger, combat: CombatState, unit: CombatUnit, cell: Vector2i) -> void:
	match trigger:
		Enum.Trigger.TURN_START:
			if not attacked:
				unit.shield_health_tile(combat, cell)
			attacked = false
		Enum.Trigger.ON_BLOCK:
			if not unit.in_turn:
				attacked = true
		Enum.Trigger.ON_HIT:
			unit.health[cell].status_effects.erase(self)


func get_color() -> Color:
	return HealthGridView.COLOR_PLATE


func get_icon() -> Texture2D:
	return preload("res://assets/grid_effects/plate.png")


## Takes Plate off unit's tile at cell, if it has any (Smash, Shred, Corrode). Returns whether it did.
static func strip(combat: CombatState, unit: CombatUnit, cell: Vector2i) -> bool:
	if not unit.health.has(cell):
		return false
	for effect in unit.health[cell].status_effects.duplicate():
		if effect is PlateTileEffect:
			unit.health[cell].status_effects.erase(effect)
			combat.record(unit, cell, Enum.Change.EFFECT_LOST, effect)
			return true
	return false
