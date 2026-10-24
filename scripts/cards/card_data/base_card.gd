@abstract class_name BaseCard
extends Resource


enum CardType { ATTACK, DEFENSE, SKILL, POWER}
var card_name: String
var cost: int
var type: CardType
var target := BaseAction.TargetType.ENEMY  # ENEMY (default) or PLAYER
var image: Texture2D
var description: String
var tiles: Array[BaseActionTile] # change to Array of Array of BaseActionTile. So that we can afford multiple Grid Actions 


## unit = the unit whose grid was clicked, cell = the clicked cell on that grid.
@abstract func execute(combat: CombatState, unit: CombatUnit, cell: Vector2i)->void


func get_description() -> String:
	return description
