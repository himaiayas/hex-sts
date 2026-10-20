class_name Slime
extends BaseEnemy


func _init() -> void:
	var coords: Array[Vector2i] = [
		Vector2i(0, 0),
		Vector2i(1, 0),
		Vector2i(0, 1),
		Vector2i(-1, 1),
		Vector2i(-1, 0),
		Vector2i(0, -1),
		Vector2i(1, -1),
		Vector2i(2, 0),
		Vector2i(1, 1),
		Vector2i(0, 2),
		Vector2i(-1, 2),
		Vector2i(-2, 1),
		Vector2i(-2, 0),
		Vector2i(-1, -1),
		Vector2i(0, -2),
		Vector2i(1, -2),
		Vector2i(2, -1),
	]
	super("Slime", CombatUnit.make_hex_health(coords))
	var tackle: Array[BaseActionTile] = [DamageTile.new(Vector2i(0, 0)), DamageTile.new(Vector2i(-1, 0))]
	var lunge: Array[BaseActionTile] = [DamageTile.new(Vector2i(0, 0)), DamageTile.new(Vector2i(1, -1))]
	actions = [make_move("Tackle", tackle), make_move("Lunge", lunge)]
