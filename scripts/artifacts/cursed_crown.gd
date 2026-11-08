class_name CursedCrown
extends BaseArtifact


func _init() -> void:
	super("Cursed Crown", "At the start of your turn, gain 1 Energy. Start each combat with 3 Fractured tiles.", Enum.ArtifactRarity.LEGENDARY,
		preload("res://assets/artifacts/cursed_crown.png"))

const FRACTURES := 3


func on_trigger(trigger: Enum.Trigger, combat: CombatState, unit: CombatUnit, _cell: Vector2i) -> void:
	match trigger:
		Enum.Trigger.TURN_START:
			combat.energy += 1
		Enum.Trigger.COMBAT_START:
			var open := func(t: HealthTile) -> bool: return undamaged(t) and not t.has_effect(FractureTileEffect)
			for cell in player_cells(combat, open).slice(0, FRACTURES):
				unit.apply_effect_health_tile(combat, cell, FractureTileEffect.new())
