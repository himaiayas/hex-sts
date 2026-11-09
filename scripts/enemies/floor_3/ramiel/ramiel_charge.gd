class_name RamielCharge
extends BaseEnemyAction

## Charges the Particle Beam, doing nothing else. The first Charge of a run locks the beam's
## target (a 3 x 10 band of Pierce), and every Charge shows it. Ramiel counts the tiles it loses
## in damage until the beam; at INTERRUPT the beam is cancelled.

const INTERRUPT := 20

var turns_left := 0  # Ramiel turns until the beam, this one included; set by Ramiel
var locked := false  # cleared by Ramiel when a new run of Charges starts
var damage := 0  # tiles Ramiel has lost since the first Charge of this run


func _init() -> void:
	super(Enum.BaseEnemyActionEnum.WIND_UP, "Charge", 1.0)
	description = "No attack. Charges the Particle Beam; losing %d tiles first cancels it." % INTERRUPT
	var band: Array[BaseActionTile] = []
	for r in 3:
		for q in 10:
			band.append(DamageTile.new(Vector2i(q - floori(r / 2.0), r), true))  # rows line up, not slant
	parts = [EnemyActionPart.new(Enum.Side.PLAYER, band)]


func plan(combat: CombatState, owner: CombatUnit) -> void:
	if not locked:
		parts[0].cell = pick_cell(parts[0], target_of(parts[0], combat, owner))
		locked = true


func delay() -> int:
	return turns_left


func intent_text() -> String:
	return "Charge: %d turn%s (%d/%d)" % [turns_left, "" if turns_left == 1 else "s", damage, INTERRUPT]


func execute(_combat: CombatState, _owner: CombatUnit) -> void:
	pass
