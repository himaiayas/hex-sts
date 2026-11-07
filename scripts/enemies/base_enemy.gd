@abstract class_name BaseEnemy
extends CombatUnit

var sprite: Texture2D
var idle_frames: Array[Texture2D] = []  # looped instead of sprite when set (bosses)
var image_size := Vector2(300, 300)  # the sprite's slot in combat
## Where its moves' hit images play, in global coords at 1920x1080. Empty = over the target's grid.
## ponytail: fixed for 16:9; derive it from the sprites' positions if wider screens need it.
var hit_vfx_area := Rect2()
var actions: Array[BaseEnemyAction] = []  # picked at random, weighted by probability, unless p1_cycle is set
var intent_action: BaseEnemyAction

## Scripted bosses: indexes into actions, played in order and looped. Below half its tiles the unit
## switches to p2_cycle for good, starting from its first move.
var p1_cycle: Array[int] = []
var p2_cycle: Array[int] = []
var in_p2 := false
var _turn := 0  # moves chosen so far in this phase


func plan(combat: CombatState) -> void: #triggered at the start of player turn
	if actions.is_empty():
		intent_action = null
		return
	intent_action = _choose_action()
	intent_action.plan(combat, self)


func take_turn(combat: CombatState) -> void:
	if intent_action == null:
		return
	await intent_action.execute(combat, self)
	intent_action = null


## The next move of p1_cycle / p2_cycle, or else weighted random by probability.
## Override for other patterns.
func _choose_action() -> BaseEnemyAction:
	if not p1_cycle.is_empty():
		var undamaged := health.values().filter(func(t: HealthTile) -> bool: return t.hp > Enum.HealthTileEnum.DAMAGED).size()
		if not in_p2 and not p2_cycle.is_empty() and undamaged * 2 < health.size():
			in_p2 = true
			_turn = 0
		var cycle := p2_cycle if in_p2 else p1_cycle
		_turn += 1
		return actions[cycle[(_turn - 1) % cycle.size()]]
	var total := 0.0
	for action in actions:
		total += action.probability
	var roll := randf() * total
	for action in actions:
		roll -= action.probability
		if roll <= 0.0:
			return action
	return actions.back()
