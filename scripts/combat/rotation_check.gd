extends SceneTree

## Headless check for GridAction.rotated. Exit code = number of failures.
## godot --headless --path . -s res://scripts/combat/rotation_check.gd

var _failures := 0


func _initialize() -> void:
	var tiles: Array[BaseActionTile] = [DamageTile.new(Vector2i(0, 0)), DamageTile.new(Vector2i(1, 0)), DamageTile.new(Vector2i(2, -1))]
	var action := GridAction.new(Enum.TargetType.ENEMY, tiles, Vector2i(-1, 0))
	var start := action.rotated(0)

	_check(start.keys() == [Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, -1)], "rotation 0 = coords + anchor")
	_check(action.rotated(1).keys() == [Vector2i(0, -1), Vector2i(0, 0), Vector2i(1, 0)], "one clockwise step")
	_check(action.rotated(-1).keys() == [Vector2i(-1, 1), Vector2i(0, 0), Vector2i(0, -1)], "one anticlockwise step = (q+r, -q)")
	_check(action.rotated(6) == start, "six steps = no rotation")
	_check(action.rotated(-1) == action.rotated(5), "-1 step = 5 steps")
	_check(tiles[1].coords == Vector2i(1, 0), "card tiles untouched")

	print("rotation_check: %s" % ("OK" if _failures == 0 else "%d failure(s)" % _failures))
	quit(_failures)


func _check(ok: bool, msg: String) -> void:
	if not ok:
		_failures += 1
		printerr("FAIL: ", msg)
