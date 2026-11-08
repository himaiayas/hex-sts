class_name SlimeSplit
extends BaseEnemyAction

## The Slime leaves the field and 2 Mini Slimes take its place. They plan at the next player turn,
## so they don't attack until the enemy turn after.


func _init() -> void:
	super(Enum.BaseEnemyActionEnum.BUFF, "Split", 1.0)
	description = "Splits into 2 Mini Slimes."


func execute(combat: CombatState, owner: CombatUnit) -> void:
	for tile in owner.health.values():  # gone, not hit: no animation, no triggers
		tile.hp = Enum.HealthTileEnum.DAMAGED
		tile.status_effects.clear()
	for i in 2:
		combat.spawn(MiniSlime.new(), owner)
