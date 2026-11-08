class_name RepeatAction
extends BaseAction

## Runs another action `times` times, each as its own hit (its own ON_HIT/ON_BLOCK, Strength and
## animation). Only the wrapped action repeats, so a card can draw once and still hit 9 times.
## In a card's grid_actions, around a GridAction, it means one click per repeat (BaseCard.placements()).

var action: BaseAction
var times: int


func _init(_action: BaseAction, _times: int) -> void:
	super(_action.target)
	action = _action
	times = _times


## Every repeat on the same unit and cell.
func execute(combat: CombatState, unit: CombatUnit, cell: Vector2i)->Array[Vector2i]:
	var hits: Array[Vector2i] = []
	for i in times:
		hits.append_array(await action.execute(combat, unit, cell))
	return hits
