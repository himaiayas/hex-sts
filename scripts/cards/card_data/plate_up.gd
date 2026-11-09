class_name PlateUp
extends BaseCard


func _init() -> void:
	card_name = "Plate Up"
	cost = 1
	type = Enum.CardType.SKILL
	description = "[Self] {render:0}\n."
	image = preload("res://assets/cards/cards/plate_up.png")
	grid_actions = [
		GridAction.new(Enum.TargetType.PLAYER, [
			ApplyEffectTile.new(Vector2i(0,0), PlateTileEffect.new()),
		]),
	]
