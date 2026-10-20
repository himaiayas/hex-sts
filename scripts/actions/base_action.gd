@abstract class_name BaseAction
extends Resource

enum TargetType {PLAYER, ENEMY}
var target: TargetType
var display_name := ""

func _init(_target: TargetType)->void:
	target = _target

@abstract func execute(ctx: ActionContext)->void
