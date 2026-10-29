@abstract class_name BaseAction
extends Resource

var target: Enum.TargetType
var display_name := ""

func _init(_target: Enum.TargetType)->void:
	target = _target

## unit = the unit whose grid is aimed at, cell = the cell on that grid.
@abstract func execute(combat: CombatState, unit: CombatUnit, cell: Vector2i)->void
