class_name Thrust
extends BaseCard


func _init() -> void:
	card_name = "Thrust"
	cost = 1
	type = Enum.CardType.ATTACK
	description = "{render:0}\nIf this damages fewer than 2 tiles, {keyword:Shield} a random tile of yours."
	grid_actions = [
		GridAction.new(Enum.TargetType.ENEMY, [
			DamageTile.new(Vector2i(0,0)),
			DamageTile.new(Vector2i(1,0)),
			DamageTile.new(Vector2i(2,0)),
		]),
	]


func execute(combat: CombatState, units: Array[CombatUnit], cells: Array[Vector2i], rotations: Array[int])->Array:
	var hits: Array = await super(combat, units, cells, rotations)
	if hits[0].size() < 2:
		await RandomTileAction.new(Enum.TargetType.PLAYER, ShieldTile.new(Vector2i.ZERO)).execute(combat, combat.player, Vector2i.ZERO)
	return hits
