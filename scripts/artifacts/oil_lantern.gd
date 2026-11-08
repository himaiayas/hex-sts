class_name OilLantern
extends BaseArtifact


func _init() -> void:
	super("Oil Lantern", "At the start of combat, gain 1 Energy.", Enum.ArtifactRarity.COMMON)

func on_trigger(trigger: Enum.Trigger, combat: CombatState, _unit: CombatUnit, _cell: Vector2i) -> void:
	if trigger == Enum.Trigger.COMBAT_START:
		combat.energy += 1
