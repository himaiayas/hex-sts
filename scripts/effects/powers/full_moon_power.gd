class_name FullMoonPower
extends BasePower

## The Werewolf's Wolf form: the first hit of each Attack card also hits EXTRA random tiles of its own
## that aren't damaged. It swaps this for New Moon when it plans a Human move.

const EXTRA := 3

var _card: BaseCard  # the last Attack card that set it off


func _init(_amount := 1) -> void:
	super("Full Moon", "Wolf form: each Attack card also hits %d more random tiles of it. Changes to New Moon next turn." % EXTRA, _amount)
	show_amount = false


func on_trigger(trigger: Enum.Trigger, combat: CombatState, unit: CombatUnit, _cell: Vector2i) -> void:
	var card := combat.playing
	if trigger != Enum.Trigger.ON_HIT or card == null or card.type != Enum.CardType.ATTACK or card == _card:
		return
	_card = card
	var open := unit.health.keys().filter(func(c: Vector2i) -> bool: return unit.health[c].hp != Enum.HealthTileEnum.DAMAGED)
	open.shuffle()
	for cell in open.slice(0, EXTRA):
		unit.damage_health_tile(combat, cell)


func get_color() -> Color:
	return Color("#ff8080")
