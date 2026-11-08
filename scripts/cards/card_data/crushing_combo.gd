class_name CrushingCombo
extends BaseCard


func _init() -> void:
	card_name = "Crushing Combo"
	cost = 1
	type = Enum.CardType.ATTACK
	rarity = Enum.CardRarity.UNCOMMON
	description = "If your core is undamaged,\n{render:0},{render:1}, and {render:2}."
	grid_actions = [
		GridAction.new(Enum.TargetType.ENEMY, [
			DamageTile.new(Vector2i(0,0)),
		]),
		GridAction.new(Enum.TargetType.ENEMY, [
			DamageTile.new(Vector2i(0,0)),
			DamageTile.new(Vector2i(1,0))
		]),
		GridAction.new(Enum.TargetType.ENEMY, [
			DamageTile.new(Vector2i(0,0)),
			DamageTile.new(Vector2i(1,0)),
			DamageTile.new(Vector2i(2,0))
		]),
	]

func execute(combat: CombatState, units: Array[CombatUnit], cells: Array[Vector2i], rotations: Array[int])->Array:
	if combat.player.health[Vector2i.ZERO].hp == Enum.HealthTileEnum.DAMAGED:
		return []
	var hits: Array = await super(combat, units, cells, rotations)
	return hits
