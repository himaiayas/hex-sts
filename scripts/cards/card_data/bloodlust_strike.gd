class_name BloodlustStrike
extends BaseCard


func _init() -> void:
	card_name = "Bloodlust Strike"
	cost = 2
	type = Enum.CardType.ATTACK
	rarity = Enum.CardRarity.RARE
	description = "Deal damage to 2 random enemy tiles for each of your tiles destroyed this combat."
	image = preload("res://assets/cards/cards/bloodlust_strike.png")


func execute(combat: CombatState, units: Array[CombatUnit], cells: Array[Vector2i], rotations: Array[int])->Array:
	var hits: Array = await super(combat, units, cells, rotations)
	var amount := 2 * combat.player_tiles_destroyed
	if amount > 0:
		hits.append(await RandomTileAction.new(Enum.TargetType.ENEMY, DamageTile.new(Vector2i.ZERO), amount).execute(combat, combat.player, Vector2i.ZERO))
	return hits
