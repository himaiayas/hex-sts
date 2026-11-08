class_name OgreWindUp
extends BaseEnemyAction

## No attack: locks where the next Smash lands and shows it, so the player can get ready.


func _init(smash: OgreSmash) -> void:
	super(Enum.BaseEnemyActionEnum.BUFF, "Wind-up", 1.0)
	description = "No attack. Aims the next Smash."
	parts = [smash.parts[0]]


func execute(_combat: CombatState, _owner: CombatUnit) -> void:
	pass
