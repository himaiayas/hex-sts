class_name OpenVein
extends BaseCard


func _init() -> void:
	card_name = "Open Vein"
	cost = 0
	type = Enum.CardType.SKILL
	description = "[Self] {render:0}\nGain 2 Energy. {keyword:Exhaust}."
	image = preload("res://assets/cards/cards/open_vein.png")
	exhaust= true
	grid_actions = [
		GridAction.new(Enum.TargetType.PLAYER, [
			ApplyEffectTile.new(Vector2i(0,0), FractureTileEffect.new()),
		], Vector2i.ZERO, true),
	]

func execute(combat: CombatState, units: Array[CombatUnit], cells: Array[Vector2i], rotations: Array[int])->Array:
	var hits: Array = await super(combat, units, cells, rotations)
	GainEnergyAction.new(Enum.TargetType.PLAYER, 2).execute(combat, combat.player, Vector2i.ZERO)
	return hits
