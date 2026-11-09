class_name EnemyWindUp
extends BaseEnemyAction

## No attack: locks where move lands next and shows it, so the player can get ready
## (Ogre's Wind-up, Plasma Turret's Charge, Android Sentinel's Aim). move keeps the cell: its plan() must not re-aim.


func _init(_name: String, _description: String, move: BaseEnemyAction) -> void:
	super(Enum.BaseEnemyActionEnum.BUFF, _name, 1.0)
	description = _description
	lands_in = 1  # the move it aims comes next turn
	parts = [move.parts[0]]


func execute(_combat: CombatState, _owner: CombatUnit) -> void:
	pass
