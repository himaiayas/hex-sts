class_name CinderStrike
extends BaseCard


func _init() -> void:
	card_name = "Cinder Strike"
	cost = 1
	type = Enum.CardType.ATTACK
	description = "{render:0}\nIf you {keyword:Exhaust}ed a card this turn, damage 2 more random enemy tiles."
	grid_actions = [
		GridAction.new(Enum.TargetType.ENEMY, [
			DamageTile.new(Vector2i(1,0)),
			DamageTile.new(Vector2i(0,0)),
			DamageTile.new(Vector2i(0,1)),
		]),
	]


func execute(combat: CombatState, units: Array[CombatUnit], cells: Array[Vector2i], rotations: Array[int])->Array:
	var hits: Array = await super(combat, units, cells, rotations)
	if combat.exhausted_this_turn > 0:
		await RandomTileAction.new(Enum.TargetType.ENEMY, DamageTile.new(Vector2i.ZERO), 2).execute(combat, null, Vector2i.ZERO)
	return hits
