class_name HeavyCuirass
extends BaseArtifact


func _init() -> void:
	super("Heavy Cuirass", "At the start of your turn, gain 1 Energy. Whenever you play a Defense, remove the {keyword:Shield} from 1 random shielded tile.", Enum.ArtifactRarity.LEGENDARY,
		preload("res://assets/artifacts/heavy_cuirass.png"))

func on_trigger(trigger: Enum.Trigger, combat: CombatState, _unit: CombatUnit, _cell: Vector2i) -> void:
	if trigger == Enum.Trigger.TURN_START:
		combat.energy += 1


func on_card_played(combat: CombatState, card: BaseCard) -> void:
	if card.type != Enum.CardType.DEFENSE:
		return
	var shielded := func(t: HealthTile) -> bool: return t.hp == Enum.HealthTileEnum.SHIELDED
	for cell in player_cells(combat, shielded).slice(0, 1):
		combat.player.health[cell].hp = Enum.HealthTileEnum.UNDAMAGED
		combat.record(combat.player, cell, Enum.Change.BLOCK)  # flashes like a shield breaking
