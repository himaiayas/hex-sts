class_name LuckyShield
extends BaseCard


func _init() -> void:
	card_name = "Lucky Shield"
	cost = 1
	type = Enum.CardType.DEFENSE
	rarity = Enum.CardRarity.UNCOMMON
	description = "Apply {keyword:Shield} to 6 random tiles."


func execute(combat: CombatState, units: Array[CombatUnit], cells: Array[Vector2i], rotations: Array[int])->Array:
	var hits: Array = await super(combat, units, cells, rotations)
	await RandomTileAction.new(Enum.TargetType.PLAYER, ShieldTile.new(Vector2i.ZERO), 6).execute(combat, null, Vector2i.ZERO)
	return hits
