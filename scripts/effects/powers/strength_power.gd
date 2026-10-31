class_name StrengthPower
extends BasePower

const DIRS: Array[Vector2i] = [
	Vector2i(1, 0), Vector2i(1, -1), Vector2i(0, -1),
	Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, 1),
]

func _init(_amount := 1) -> void:
	super("Strength", "Each tile your attacks damage also damages 1 random adjacent tile per Strength, if any are left.", _amount)

func get_color() -> Color:
	return Color("#ff9a3c")


## Extra damage for the tiles an attack just damaged on unit, from the acting unit's Strength.
## Each damaged tile hits up to that many random undamaged neighbours. Extras don't spread again.
## Returns the extra tiles damaged.
static func spread(combat: CombatState, unit: CombatUnit, damaged: Array[Vector2i]) -> Array[Vector2i]:
	var extras: Array[Vector2i] = []
	var attacker := combat.acting_unit()
	var strength := attacker.power_amount(StrengthPower) if attacker else 0
	if strength <= 0:
		return extras
	for cell in damaged:
		var open: Array[Vector2i] = []
		for dir in DIRS:
			var next := cell + dir
			if unit.health.has(next) and unit.health[next].hp != Enum.HealthTileEnum.DAMAGED:
				open.append(next)
		open.shuffle()
		for next in open.slice(0, strength):
			if unit.damage_health_tile(combat, next):
				extras.append(next)
	return extras
