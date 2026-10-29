class_name CrimsonShard
extends BaseArtifact

func _init() -> void:
	super(
		"Crimson Shard", 
		"At the start of your turn, deal 1 damage to a random enemy tile.", 
		Enum.ArtifactRarity.COMMON)

func on_trigger(trigger: Enum.Trigger, combat: CombatState, _unit: CombatUnit, _cell: Vector2i) -> void:
	if trigger != Enum.Trigger.TURN_START or combat.enemies.is_empty():
		return
	var enemy: CombatUnit = combat.enemies[0]  
	var cells := enemy.health.keys().filter(func(c: Vector2i) -> bool:
		return enemy.health[c].hp > Enum.HealthTileEnum.DAMAGED)
	if not cells.is_empty():
		enemy.damage_health_tile(combat, cells.pick_random())
