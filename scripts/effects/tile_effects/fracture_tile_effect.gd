class_name FractureTileEffect
extends BaseTileEffect

## When its tile is damaged, each neighbour takes 1 hit (a Shield there absorbs it as usual).
## It doesn't chain: a hit from Fracture doesn't set off another Fracture.

static var _spreading := false  # a Fracture is hitting its neighbours right now


func _init() -> void:
	super("Fracture", "When this tile is damaged, each tile next to it takes 1 damage.")
	debuff = true


func on_trigger(trigger: Enum.Trigger, combat: CombatState, unit: CombatUnit, cell: Vector2i) -> void:
	if trigger != Enum.Trigger.ON_HIT:
		return
	unit.health[cell].status_effects.erase(self)
	if _spreading:
		return
	_spreading = true
	for dir in StrengthPower.DIRS:
		if unit.health.has(cell + dir):
			unit.damage_health_tile(combat, cell + dir)
	_spreading = false


func get_color() -> Color:
	return Color("#d9a066")


func get_icon() -> Texture2D:
	return preload("res://assets/grid_effects/fracture.png")
