class_name BurningHeadPower
extends BasePower

## When one Attack card destroys THRESHOLD of its owner's tiles, the attacker takes amount hits on random
## tiles that aren't damaged (a Shield there absorbs it). Once per card.

const THRESHOLD := 6

var _card: BaseCard  # the card counted so far
var _lost := 0  # tiles it destroyed


func _init(_amount := 1) -> void:
	super("Burning Head", "When one Attack card destroys %d of its tiles, it burns 1 random tile of the attacker per Burning Head." % THRESHOLD, _amount)


func get_description() -> String:
	return "When one Attack card destroys %d of its tiles, it burns %s of the attacker." % [THRESHOLD, plural(amount, "random tile")]


func on_trigger(trigger: Enum.Trigger, combat: CombatState, _unit: CombatUnit, _cell: Vector2i) -> void:
	var card := combat.playing
	if trigger != Enum.Trigger.ON_HIT or card == null or card.type != Enum.CardType.ATTACK:
		return
	if card != _card:
		_card = card
		_lost = 0
	_lost += 1
	if _lost != THRESHOLD:
		return
	var player := combat.player
	var open := player.health.keys().filter(func(c: Vector2i) -> bool: return player.health[c].hp != Enum.HealthTileEnum.DAMAGED)
	open.shuffle()
	for cell in open.slice(0, amount):
		player.damage_health_tile(combat, cell)


func get_color() -> Color:
	return Color("#ff8c2a")
