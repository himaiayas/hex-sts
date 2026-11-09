class_name BatBite
extends EnemyHit

## Hit 4, then heals HEAL random damaged tiles of its own.

const HEAL := 3


func _init() -> void:
	var bite: Array[BaseActionTile] = [
		DamageTile.new(Vector2i(0, 0)),
		DamageTile.new(Vector2i(1, 0)),
		DamageTile.new(Vector2i(-1, 1)),
		DamageTile.new(Vector2i(0, 1)),
	]
	super("Bite", "Hit 4 tiles, then heal 3 of its own.", bite)
	extra_types = [Enum.BaseEnemyActionEnum.BUFF]  # the heal
	add_own_effect(HealTile, HEAL)


func execute(combat: CombatState, owner: CombatUnit) -> void:
	await super(combat, owner)
	await inflict_random_own(combat, owner, HealTile.new(Vector2i.ZERO), HEAL)
