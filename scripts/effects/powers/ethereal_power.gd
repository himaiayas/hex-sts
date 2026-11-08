class_name EtherealPower
extends BasePower

## One Attack card can only land amount hits on its owner; the rest miss and flash like a block.

var _card: BaseCard  # the card counted so far
var _hits := 0


func _init(_amount := 1) -> void:
	super("Ethereal", "One Attack card can only hit it 1 time per Ethereal; the rest miss.", _amount)


func get_description() -> String:
	return "One Attack card can only hit it %d time%s; the rest miss." % [amount, "" if amount == 1 else "s"]


func dodges(combat: CombatState, _unit: CombatUnit) -> bool:
	var card := combat.playing
	if card == null or card.type != Enum.CardType.ATTACK:
		return false
	if card != _card:
		_card = card
		_hits = 0
	_hits += 1
	return _hits > amount


func get_color() -> Color:
	return Color("#c8d6ff")
