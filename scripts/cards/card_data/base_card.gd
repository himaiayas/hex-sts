@abstract class_name BaseCard
extends Resource


enum CardType { ATTACK, DEFENSE, SKILL, POWER}
var card_name: String
var cost: int
var type: CardType
var target := BaseAction.TargetType.ENEMY  # ENEMY (default) or PLAYER
var image: Texture2D
var description: String
var grid_actions: Array[GridAction] = []  # each is its own pattern, drawn with {render:N}


## units[i], cells[i], rotations[i] = the grid, cell and rotation chosen for grid_actions[i], in order.
## Runs every grid action at its own cell. Override and call super() to add other actions.
func execute(combat: CombatState, units: Array[CombatUnit], cells: Array[Vector2i], rotations: Array[int])->void:
	for i in grid_actions.size():
		grid_actions[i].execute(combat, units[i], cells[i], rotations[i])


func get_description() -> String:
	return description
