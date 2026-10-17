@abstract class_name BaseAction
extends Resource

enum TargetType {PLAYER, ENEMY}
var target: TargetType

func _init(_target: TargetType)->void:
    target = _target

@abstract func execute(ctx: ActionContext)->void
