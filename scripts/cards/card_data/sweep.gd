class_name Sweep
extends BaseCard


func _init() -> void:
	card_name = "Sweep"
	cost = 1
	type = Enum.CardType.ATTACK
	description = "{render:0}\nPut a card from your discard pile on top of your draw pile."
	image = preload("res://assets/cards/cards/sweep.png")
	grid_actions = [
		GridAction.new(Enum.TargetType.ENEMY, [
			DamageTile.new(Vector2i(0,0)),
			DamageTile.new(Vector2i(1,0)),
			DamageTile.new(Vector2i(-1,0)),

		]),
	]


func execute(combat: CombatState, units: Array[CombatUnit], cells: Array[Vector2i], rotations: Array[int])->Array:
	var hits: Array = await super(combat, units, cells, rotations)
	await DiscardToDrawTopAction.new(1).execute(combat, combat.player, Vector2i.ZERO)
	return hits
