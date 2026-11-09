class_name TitanPlate
extends BaseArtifact


func _init() -> void:
	super("Titan Plate", "At the start of combat, apply {keyword:Plate} to 4 random tiles.", Enum.ArtifactRarity.RARE,
		preload("res://assets/artifacts/titan_plate.png"))

const PLATES := 4


func on_trigger(trigger: Enum.Trigger, combat: CombatState, unit: CombatUnit, _cell: Vector2i) -> void:
	if trigger != Enum.Trigger.COMBAT_START:
		return
	var open := func(t: HealthTile) -> bool: return undamaged(t) and not t.has_effect(PlateTileEffect)
	for cell in player_cells(combat, open).slice(0, PLATES):
		unit.apply_effect_health_tile(combat, cell, PlateTileEffect.new())
