class_name PhoenixFeather
extends BaseArtifact


func _init() -> void:
	super("Phoenix Feather", "The first time you die, revive with your core and the 6 tiles around it healed. Once per run.", Enum.ArtifactRarity.RARE)

var used := false


func revive(combat: CombatState, unit: CombatUnit) -> bool:
	if used:
		return false
	used = true
	description = "Used: it already saved you once."
	for cell in [Vector2i.ZERO] + DIRS:
		if unit.health.has(cell):
			unit.heal_health_tile(combat, cell)
	return true
