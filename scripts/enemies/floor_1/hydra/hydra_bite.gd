class_name HydraBite
extends EnemyHit

## One random 4-tile bite per head. Its intent counts the tiles lost toward cutting a head,
## until a head is cut this turn.

var heads: MultiHeadPower


func _init(count: int, _heads: MultiHeadPower) -> void:
	var bite: Array[BaseActionTile] = [
		DamageTile.new(Vector2i(0, 0)),
		DamageTile.new(Vector2i(1, 0)),
		DamageTile.new(Vector2i(0, 1)),
	]
	super("Bite", "Hit 3 tiles %d time%s." % [count, "" if count == 1 else "s"], bite, count, true)
	heads = _heads


func intent_text() -> String:
	if heads.cut:
		return action_name
	return "%s (%d/%d)" % [action_name, heads.lost, MultiHeadPower.CUT]
