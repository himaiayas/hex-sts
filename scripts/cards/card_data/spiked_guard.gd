class_name SpikedGuard
extends BaseCard


func _init() -> void:
	card_name = "Spiked Guard"
	cost = 2
	type = Enum.CardType.DEFENSE
	target = Enum.TargetType.PLAYER
	description = "{render:0}\nGain 1 {keyword:Retaliate} this turn."
	grid_actions = [
		GridAction.new(Enum.TargetType.PLAYER, [
			ShieldTile.new(Vector2i(0,0)),
			ShieldTile.new(Vector2i(1,0)),
			ShieldTile.new(Vector2i(0,1)),
			ShieldTile.new(Vector2i(-1,1)),
		]),
	]


func execute(combat: CombatState, units: Array[CombatUnit], cells: Array[Vector2i], rotations: Array[int])->Array:
	var hits: Array = await super(combat, units, cells, rotations)
	await ApplyPowerAction.new(Enum.TargetType.PLAYER, RetaliatePower.new(1)).execute(combat, combat.player, Vector2i.ZERO)
	return hits
