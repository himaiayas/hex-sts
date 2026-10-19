class_name ShieldEnemy
extends BaseCard


func _init() -> void:
	card_name = "Shield Enenmy"
	cost = 1
	type = CardType.DEFENSE
	description = "fdksmfdf."
	tiles = [
        ShieldTile.new(Vector2i(0,0)),
	]

func execute(ctx: ActionContext)->void:
	GridAction.new(BaseAction.TargetType.ENEMY, tiles).execute(ctx)
