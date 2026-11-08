class_name DiscardFromHandAction
extends BaseAction

## The player picks amount cards in their hand to discard.

var amount: int

func _init(_amount := 1)->void:
	super(Enum.TargetType.PLAYER)
	amount = _amount

func execute(combat: CombatState, _unit: CombatUnit, _cell: Vector2i)->Array[Vector2i]:
	var prompt := "Pick %d card%s in your hand to discard." % [amount, "" if amount == 1 else "s"]
	for card in await combat.choose_cards(combat.hand.duplicate(), amount, prompt, true):
		combat.discard(card)
	return []
