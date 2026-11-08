class_name GiantsKnuckle
extends BaseArtifact


func _init() -> void:
	super("Giant's Knuckle", "At the start of combat, gain 1 Strength.", Enum.ArtifactRarity.RARE,
		preload("res://assets/artifacts/giants_knuckle.png"))

func on_trigger(trigger: Enum.Trigger, combat: CombatState, unit: CombatUnit, _cell: Vector2i) -> void:
	if trigger == Enum.Trigger.COMBAT_START:
		unit.add_power(combat, StrengthPower.new(1))
