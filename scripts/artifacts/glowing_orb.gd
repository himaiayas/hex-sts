class_name GlowingOrb
extends BaseArtifact

const ENERGY := 2

func _init() -> void:
	super("Glowing Orb", "At the start of combat, gain %d Energy." % ENERGY, Enum.ArtifactRarity.RARE)

func on_trigger(trigger: Enum.Trigger, combat: CombatState, _unit: CombatUnit, _cell: Vector2i) -> void:
	if trigger == Enum.Trigger.COMBAT_START:
		combat.energy += ENERGY
