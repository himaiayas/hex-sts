@abstract class_name BaseCard
extends Resource


enum CardType { ATTACK, DEFENSE, SKILL, POWER}
var card_name: String
var cost: int
var type: CardType
var target := BaseAction.TargetType.ENEMY  # ENEMY (default) or PLAYER
var image: Texture2D
var description: String
var tiles: Array[BaseActionTile]


@abstract func execute(ctx: ActionContext)->void


func get_description() -> String:
	return description
