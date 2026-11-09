class_name DonutBlast
extends BaseCard


func _init() -> void:
	card_name = "Donut Blast"
	cost = 1
	type = Enum.CardType.ATTACK
	rarity = Enum.CardRarity.UNCOMMON
	target = Enum.TargetType.ENEMY
	description = "{render:0}\nIf this card destroys {keyword:Fracture} tile, Gain 1 energy, Draw 2 cards."
	image = preload("res://assets/cards/cards/donut_blast.png")
	grid_actions = [
		GridAction.new(Enum.TargetType.ENEMY, [
			DamageTile.new(Vector2i(1,0)),
			DamageTile.new(Vector2i(0,1)),
			DamageTile.new(Vector2i(1,-1)),
			DamageTile.new(Vector2i(0,-1)),
			DamageTile.new(Vector2i(-1,0)),
			DamageTile.new(Vector2i(-1,1)),
		]),
	]


func execute(combat: CombatState, units: Array[CombatUnit], cells: Array[Vector2i], rotations: Array[int])->Array:
	var fractured := [] 
	for i in cells.size():
		for offset in grid_action(i).rotated(rotations[i]):
			var cell := cells[i] + offset
			if units[i].health.has(cell) and units[i].health[cell].has_effect(FractureTileEffect):
				fractured.append([units[i], cell])
	var hits: Array = await super(combat, units, cells, rotations)
	for i in hits.size():
		for cell in hits[i]:
			if [units[i], cell] in fractured:
				GainEnergyAction.new(1).execute(combat, combat.player, Vector2i.ZERO)
				DrawAction.new(Enum.TargetType.PLAYER, 1).execute(combat, combat.player, Vector2i.ZERO)
	return hits
