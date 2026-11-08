class_name DiscardToDrawTopAction
extends BaseAction

## The player picks amount cards in the discard pile to put on top of the draw pile.

var amount: int

func _init(_amount := 1)->void:
	super(Enum.TargetType.PLAYER)
	amount = _amount

func execute(combat: CombatState, _unit: CombatUnit, _cell: Vector2i)->Array[Vector2i]:
	var prompt := "Pick %d card%s to put on top of your draw pile." % [amount, "" if amount == 1 else "s"]
	for card in await combat.choose_cards(combat.discard_pile.duplicate(), amount, prompt, false):
		combat.discard_pile.erase(card)
		combat.draw_pile.append(card)  # draw() takes from the back
	return []
