class_name WeightedBoots
extends BaseArtifact


func _init() -> void:
	super("Weighted Boots", "At the start of combat, apply Fracture to 1 random enemy tile.", Enum.ArtifactRarity.UNCOMMON)

func on_trigger(trigger: Enum.Trigger, combat: CombatState, _unit: CombatUnit, _cell: Vector2i) -> void:
	if trigger != Enum.Trigger.COMBAT_START:
		return
	var open := func(t: HealthTile) -> bool: return undamaged(t) and not t.has_effect(FractureTileEffect)
	for pick in enemy_cells(combat, open).slice(0, 1):
		pick[0].apply_effect_health_tile(combat, pick[1], FractureTileEffect.new())
