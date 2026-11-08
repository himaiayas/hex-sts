class_name DuelistPower
extends BasePower

## Every 3rd Attack the player plays in a turn (3rd, 6th, ...) shields amount random undamaged tiles
## of theirs. The count resets at the start of each turn.

const ATTACKS := 3

var attacks := 0  # Attacks played this turn


func _init(_amount := 1) -> void:
	super("Duelist", "Every time you play 3 Attacks in a single turn, Shield 1 random tile per Duelist.", _amount)


func get_description() -> String:
	return "Every time you play %d Attacks in a single turn, Shield %s. (%d/%d this turn.)" % [
		ATTACKS, plural(amount, "random tile"), attacks % ATTACKS, ATTACKS]


func on_trigger(trigger: Enum.Trigger, _combat: CombatState, _unit: CombatUnit, _cell: Vector2i) -> void:
	if trigger == Enum.Trigger.TURN_START:
		attacks = 0


func on_card_played(combat: CombatState, unit: CombatUnit, card: BaseCard) -> void:
	if card.type != Enum.CardType.ATTACK:
		return
	attacks += 1
	if attacks % ATTACKS != 0:
		return
	var shield := ShieldTile.new(Vector2i.ZERO)
	var cells := unit.health.keys().filter(func(c: Vector2i) -> bool: return shield.can_inflict(unit, c))
	cells.shuffle()
	for cell in cells.slice(0, amount):
		shield.inflict(combat, unit, cell)


func get_color() -> Color:
	return Color("#a0e5f6")
