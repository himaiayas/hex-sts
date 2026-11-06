@abstract class_name BaseAction
extends Resource

var target: Enum.TargetType
var display_name := ""

func _init(_target: Enum.TargetType)->void:
	target = _target

## unit = the unit whose grid is aimed at, cell = the cell on that grid.
## Returns the cells it changed (empty for actions that don't touch a grid).
## Actions that change tiles or powers flush them, so await those.
@abstract func execute(combat: CombatState, unit: CombatUnit, cell: Vector2i)->Array[Vector2i]
