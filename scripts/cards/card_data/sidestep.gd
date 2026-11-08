class_name Sidestep
extends BaseCard


func _init() -> void:
	card_name = "Sidestep"
	cost = 1
	type = Enum.CardType.DEFENSE
	target = Enum.TargetType.PLAYER
	description = "{render:0}\nDraw a card."
	image = preload("res://assets/cards/cards/sidestep.png")
	grid_actions = [
		GridAction.new(Enum.TargetType.PLAYER, [
			ShieldTile.new(Vector2i(0,0)),
			ShieldTile.new(Vector2i(1,0)),
		]),
	]

func execute(combat: CombatState, units: Array[CombatUnit], cells: Array[Vector2i], rotations: Array[int])->Array:
	var hits: Array = await super(combat, units, cells, rotations)
	DrawAction.new(Enum.TargetType.PLAYER, 1).execute(combat, combat.player, Vector2i.ZERO)
	return hits
