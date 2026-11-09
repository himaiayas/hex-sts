class_name BurningStab
extends BaseCard


func _init() -> void:
	card_name = "Burning Stab"
	cost = 1
	type = Enum.CardType.ATTACK
	description = "{keyword:Exhaust} 1 random card in your hand.\n{render:0}"
	image = preload("res://assets/cards/cards/burning_stab.png")
	grid_actions = [
		GridAction.new(Enum.TargetType.ENEMY, [
			DamageTile.new(Vector2i.ZERO, true),
			DamageTile.new(Vector2i(1,0), true),
			DamageTile.new(Vector2i(1,1), true),
			DamageTile.new(Vector2i(-1,0), true),
		]),
	]


## Needs another card in hand to exhaust.
func can_play(combat: CombatState) -> bool:
	return combat.hand.size() > 1


## Exhausts a random card from the hand first, as the price of the attack.
func execute(combat: CombatState, units: Array[CombatUnit], cells: Array[Vector2i], rotations: Array[int])->Array:
	if not combat.hand.is_empty():
		combat.exhaust(combat.hand.pick_random())
	return await super(combat, units, cells, rotations)
