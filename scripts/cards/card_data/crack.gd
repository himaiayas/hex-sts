class_name Crack
extends BaseCard


func _init() -> void:
	card_name = "Crack"
	cost = 1
	type = Enum.CardType.SKILL
	description = "{render:0}\nApply {keyword:Fracture}."
	image = preload("res://assets/cards/cards/crack.png")
	grid_actions = [
		GridAction.new(Enum.TargetType.ENEMY, [
			ApplyEffectTile.new(Vector2i(0,0), FractureTileEffect.new()),
		]),
	]
