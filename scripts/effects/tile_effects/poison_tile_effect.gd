class_name PoisonTileEffect
extends BaseTileEffect

func _init() -> void:
	super("Poison", "At the start of its owner's turn, the tile takes 1 damage", 1)

func on_trigger(trigger: Enum.Trigger, combat: CombatState, unit: CombatUnit, cell: Vector2i) -> void:
	if trigger == Enum.Trigger.TURN_START:
		unit.damage_health_tile(combat, cell)

func get_color() -> Color:
	return Color("#00ff00")  # Green color for poison
