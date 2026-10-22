@abstract class_name BaseAction
extends Resource

enum TargetType {PLAYER, ENEMY}
var target: TargetType
var display_name := ""

func _init(_target: TargetType)->void:
	target = _target

## unit = the unit whose grid is aimed at, cell = the cell on that grid.
@abstract func execute(combat: CombatState, unit: CombatUnit, cell: Vector2i)->void
