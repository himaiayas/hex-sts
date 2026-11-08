class_name Taunt
extends BaseCard


func _init() -> void:
	card_name = "Taunt"
	cost = 1
	type = Enum.CardType.SKILL
	target = Enum.TargetType.PLAYER
	description = "Move enemy attack aimed at you this turn. It must still hit at least 1 tile fewer."
	image = preload("res://assets/cards/cards/taunt.png")
	


## One enemy attack at a time: click where it goes, or Confirm to leave it.
func execute(combat: CombatState, units: Array[CombatUnit], cells: Array[Vector2i], rotations: Array[int])->Array:
	var hits: Array = await super(combat, units, cells, rotations)
	await combat.relocate_intents()
	return hits
