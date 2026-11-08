class_name Hydra
extends BaseEnemy

## Floor 1, Elite. Bites once per head (Multi-head, 3 heads). Losing 10 tiles in one player turn
## cuts a head at once: the intent drops a bite and the sprite loses a head. With no heads left it
## stops attacking. Regen 3, unless it lost 8 or more tiles in the player's turn.

const HEADS := 3
const REGEN := 3
const REGEN_GUARD := 8
## The sprite for each number of heads left.
const ART: Array[Texture2D] = [
	preload("res://assets/enemies/floor_1/hydra_beheaded.png"),
	preload("res://assets/enemies/floor_1/hydra_1_head.png"),
	preload("res://assets/enemies/floor_1/hydra_2_heads.png"),
	preload("res://assets/enemies/floor_1/hydra.png"),
]

var _bites: Array[HydraBite] = []  # _bites[n - 1] bites n times


func _init() -> void:
	var coords: Array[Vector2i] = [
		Vector2i(2, -6), Vector2i(3, -6), Vector2i(4, -6),
		Vector2i(2, -5), Vector2i(3, -5),
		Vector2i(-2, -4), Vector2i(-1, -4), Vector2i(0, -4), Vector2i(2, -4), Vector2i(4, -4), Vector2i(5, -4), Vector2i(6, -4),
		Vector2i(-2, -3), Vector2i(-1, -3), Vector2i(1, -3), Vector2i(2, -3), Vector2i(4, -3), Vector2i(5, -3),
		Vector2i(-2, -2), Vector2i(1, -2), Vector2i(4, -2),
		Vector2i(-3, -1), Vector2i(-2, -1), Vector2i(0, -1), Vector2i(1, -1), Vector2i(3, -1), Vector2i(4, -1),
		Vector2i(-3, 0), Vector2i(-2, 0), Vector2i(0, 0), Vector2i(3, 0),
		Vector2i(-4, 1), Vector2i(-3, 1), Vector2i(-2, 1), Vector2i(-1, 1), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1),
		Vector2i(-4, 2), Vector2i(-3, 2), Vector2i(-2, 2), Vector2i(-1, 2), Vector2i(0, 2), Vector2i(1, 2), Vector2i(2, 2),
		Vector2i(-4, 3), Vector2i(-3, 3), Vector2i(-2, 3), Vector2i(-1, 3), Vector2i(0, 3), Vector2i(1, 3),
		Vector2i(-3, 4), Vector2i(-2, 4), Vector2i(-1, 4),
	]
	super("Hydra", CombatUnit.make_hex_health(coords))
	sprite = ART[HEADS]
	idle_frames = [sprite]  # its UnitImage shares this array, so a cut head shows at once
	image_size = Vector2(680, 680)  # as big as the Dragon
	var heads := MultiHeadPower.new(HEADS)
	for n in range(1, HEADS + 1):
		_bites.append(HydraBite.new(n, heads))
	actions.assign(_bites)
	statuses.append(heads)
	statuses.append(RegenPower.new(REGEN, REGEN_GUARD))


func _choose_actions() -> Array[BaseEnemyAction]:
	var heads := power_amount(MultiHeadPower)
	if heads == 0:
		return []
	return [_bites[heads - 1]]


## A cut head takes its bite out of the planned intent; the other bites keep their spots.
func fire_at(trigger: Enum.Trigger, combat: CombatState, cell: Vector2i) -> void:
	var heads := power_amount(MultiHeadPower)
	super(trigger, combat, cell)
	if power_amount(MultiHeadPower) == heads:
		return
	heads -= 1
	idle_frames[0] = ART[heads]
	if intent_actions.is_empty():
		return
	var planned := intent_actions[0]
	if heads == 0:
		intent_actions = []
		return
	var bite := _bites[heads - 1]
	for i in bite.parts.size():
		bite.parts[i].cell = planned.parts[i].cell
	intent_actions = [bite]
