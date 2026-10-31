class_name ArrowRain
extends BaseCard


func _init() -> void:
	card_name = "Arrow Rain"
	cost = 1
	type = Enum.CardType.ATTACK
	description = "Damage 5 random tiles among all enemies."


func execute(combat: CombatState, units: Array[CombatUnit], cells: Array[Vector2i], rotations: Array[int])->Array:
	var hits := super(combat, units, cells, rotations)
	RandomTileAction.new(Enum.TargetType.ENEMY, DamageTile.new(Vector2i.ZERO), 5).execute(combat, null, Vector2i.ZERO)
	return hits
