class_name WornGauntlet
extends BaseArtifact


func _init() -> void:
	super("Worn Gauntlet", "After winning a combat, heal 2 random damaged tiles.", Enum.ArtifactRarity.UNCOMMON)

const HEALS := 2


func on_combat_end(combat: CombatState) -> void:
	for cell in player_cells(combat, func(t: HealthTile) -> bool: return not undamaged(t)).slice(0, HEALS):
		combat.player.health[cell].hp = Enum.HealthTileEnum.UNDAMAGED
