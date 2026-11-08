class_name SturdySteps
extends BaseCard


func _init() -> void:
	card_name = "Sturdy Steps"
	cost = 1
	type = Enum.CardType.ATTACK
	rarity = Enum.CardRarity.UNCOMMON
	description = "{render:0}\nIf you played a Defense this turn, deal damage to 3 random enemy tiles."
	image = preload("res://assets/cards/cards/sturdy_steps.png")
	grid_actions = [
		GridAction.new(Enum.TargetType.ENEMY, [
			DamageTile.new(Vector2i(-2,0)),
			DamageTile.new(Vector2i(-1,0)),
			DamageTile.new(Vector2i(0,0)),
			DamageTile.new(Vector2i(1,0)),
			DamageTile.new(Vector2i(2,0)),
		]),
	]


func execute(combat: CombatState, units: Array[CombatUnit], cells: Array[Vector2i], rotations: Array[int])->Array:
	var hits: Array = await super(combat, units, cells, rotations)
	if combat.played_this_turn.any(func(c: BaseCard) -> bool: return c.type == Enum.CardType.DEFENSE):
		hits.append(await RandomTileAction.new(Enum.TargetType.ENEMY, DamageTile.new(Vector2i.ZERO), 3).execute(combat, combat.player, Vector2i.ZERO))
	return hits
