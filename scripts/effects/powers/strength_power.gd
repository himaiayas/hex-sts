class_name StrengthPower
extends BasePower

const DIRS: Array[Vector2i] = [
	Vector2i(1, 0), Vector2i(1, -1), Vector2i(0, -1),
	Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, 1),
]

var this_turn := 0  # the part of amount that goes away at the end of the owner's turn


## this_turn: the whole amount only lasts until the end of the owner's turn.
func _init(_amount := 1, _this_turn := false) -> void:
	super("Strength", "Each attack also damages 1 random tile next to the tiles it hit per Strength, if any are left.", _amount)
	if _this_turn:
		this_turn = _amount


func on_trigger(trigger: Enum.Trigger, _combat: CombatState, unit: CombatUnit, _cell: Vector2i) -> void:
	if trigger == Enum.Trigger.TURN_END and this_turn > 0:
		amount -= this_turn
		this_turn = 0
		if amount <= 0:
			unit.statuses.erase(self)


func copy() -> BaseEffect:
	var power := super() as StrengthPower
	power.this_turn = this_turn
	return power


func stack(other: BaseEffect) -> void:
	super(other)
	this_turn += (other as StrengthPower).this_turn

func get_color() -> Color:
	return Color("#ff9a3c")


## Extra damage after one attack, from the acting unit's Strength. landed = [unit, cell] for every
## cell the attack's damage tiles landed on (damaged, blocked by a shield, or already damaged).
## Picks that many random tiles, each next to a landed cell, not damaged and not landed on
## (a shield there absorbs the hit as usual). Only on the other side's grids. Extras don't spread again.
## Returns the extra tiles damaged.
static func spread(combat: CombatState, landed: Array) -> Array[Vector2i]:
	var extras: Array[Vector2i] = []
	var attacker := combat.acting_unit()
	var strength := attacker.power_amount(StrengthPower) if attacker else 0
	if strength <= 0:
		return extras
	var open := []  # [unit, cell], each once
	for hit in landed:
		var unit: CombatUnit = hit[0]
		if unit.is_player == attacker.is_player:
			continue  # not on your own side's grid
		for dir in DIRS:
			var next: Vector2i = hit[1] + dir
			if unit.health.has(next) and unit.health[next].hp != Enum.HealthTileEnum.DAMAGED \
					and [unit, next] not in landed and [unit, next] not in open:
				open.append([unit, next])
	open.shuffle()
	for pick in open.slice(0, strength):
		if pick[0].damage_health_tile(combat, pick[1]):
			extras.append(pick[1])
	return extras
