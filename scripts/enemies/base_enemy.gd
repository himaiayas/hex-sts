@abstract class_name BaseEnemy
extends CombatUnit

var sprite: Texture2D
var actions: Array[BaseEnemyAction] = []  # picked at random, weighted by probability
var intent_action: BaseEnemyAction


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


## Weighted random by probability. Override for loops or scripted patterns.
func _choose_action() -> BaseEnemyAction:
	var total := 0.0
	for action in actions:
		total += action.probability
	var roll := randf() * total
	for action in actions:
		roll -= action.probability
		if roll <= 0.0:
			return action
	return actions.back()
