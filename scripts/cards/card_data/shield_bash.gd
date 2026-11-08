class_name ShieldBash
extends BaseCard


func _init() -> void:
	card_name = "Shield Bash"
	cost = 1
	type = Enum.CardType.ATTACK
	description = "{render:0}\nFor every 2 shielded tiles you have, deal 1 damage to random tiles."
	image = preload("res://assets/cards/cards/shield_bash.png")
	grid_actions = [
		GridAction.new(Enum.TargetType.ENEMY, [
			DamageTile.new(Vector2i(1,0)),
			DamageTile.new(Vector2i(0,0)),
		]),
	]


func execute(combat: CombatState, units: Array[CombatUnit], cells: Array[Vector2i], rotations: Array[int])->Array:
	var hits: Array = await super(combat, units, cells, rotations)
	var shielded_tiles = 0
	for tile in combat.player.health.values():
		if tile.is_shielded():
			shielded_tiles += 1
	if shielded_tiles > 1:
		await RandomTileAction.new(Enum.TargetType.ENEMY, DamageTile.new(Vector2i.ZERO), shielded_tiles / 2).execute(combat, null, Vector2i.ZERO)
	return hits
