class_name PoisonTileEffect
extends BaseTileEffect

## Explodes at the start of its owner's 2nd turn after it's applied: its tile is damaged through Shield
## and Plate, and each neighbour takes 1 hit (a Shield there absorbs it). It stays on its tile if the tile
## is damaged first, and a neighbour's Poison hit by the explosion keeps its own countdown.

var countdown := 2  # owner's turn starts left until it explodes


func _init() -> void:
	super("Poison", "Explodes at the start of its owner's 2nd turn: this tile is damaged through Shield and Plate, and each tile next to it takes 1 damage.")
	allow_damaged = true

func on_trigger(trigger: Enum.Trigger, combat: CombatState, unit: CombatUnit, cell: Vector2i) -> void:
	if trigger != Enum.Trigger.TURN_START:
		return
	countdown -= 1
	if countdown > 0:
		return
	unit.health[cell].status_effects.erase(self)
	unit.damage_health_tile(combat, cell, true)
	for dir in StrengthPower.DIRS:
		if unit.health.has(cell + dir):
			unit.damage_health_tile(combat, cell + dir)

func get_color() -> Color:
	return Color("#00ff00")  # Green color for poison

func get_icon() -> Texture2D:
	return preload("res://assets/grid_effects/poison.png")
