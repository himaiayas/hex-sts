class_name IronRing
extends BaseArtifact


func _init() -> void:
	super("Iron Ring", "At the start of combat, Shield 4 random tiles.", Enum.ArtifactRarity.COMMON)

const SHIELDS := 4


func on_trigger(trigger: Enum.Trigger, combat: CombatState, unit: CombatUnit, _cell: Vector2i) -> void:
	if trigger != Enum.Trigger.COMBAT_START:
		return
	var open := func(t: HealthTile) -> bool: return t.hp == Enum.HealthTileEnum.UNDAMAGED
	for cell in player_cells(combat, open).slice(0, SHIELDS):
		unit.shield_health_tile(combat, cell)
