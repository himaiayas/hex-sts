class_name PlateTileEffect
extends BaseTileEffect

## Not implemented yet (sheet draft only): the 20-hex cap and Shred / Corrode. Smash is OgreSmash.

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
