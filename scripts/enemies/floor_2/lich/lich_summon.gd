class_name LichSummon
extends BaseEnemyAction

## Summons a Lil Ghost beside the Lich. It plans at the next player turn, so it doesn't attack until
## the enemy turn after.


func _init() -> void:
	super(Enum.BaseEnemyActionEnum.BUFF, "Summon Lil Ghost", 1.0)
	description = "Summon a Lil Ghost."


func execute(combat: CombatState, owner: CombatUnit) -> void:
	var ghost := LilGhost.new()
	ghost.image_size = Vector2(150, 150)  # half the usual, to fit beside the Lich
	(owner as Lich).summons.append(ghost)
	combat.spawn(ghost, owner, false)
