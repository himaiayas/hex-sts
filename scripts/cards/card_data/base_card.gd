@abstract class_name BaseCard
extends Resource


var card_name: String
var cost: int
var type: Enum.CardType
var target := Enum.TargetType.ENEMY  # ENEMY (default) or PLAYER
var image: Texture2D
var description: String
var rarity: Enum.CardRarity = Enum.CardRarity.COMMON
var exhaust := false  # goes to the exhaust pile after it's played, gone until the next fight
var retain := false  # stays in hand at the end of the turn
var to_draw_top := false  # goes on top of the draw pile after it's played, instead of the discard pile
var exhaust_from_hand := 0  # cards in hand the player picks to exhaust when playing it
var pick_from_discard := 0  # cards in the discard pile the player picks to put on top of the draw pile
var pick_tiles := 0  # tiles of yours the player picks when playing it, and pick_tile is inflicted on each
var pick_tile: BaseActionTile = null
var grid_actions: Array[GridAction] = []  # each is its own pattern, drawn with {render:N}
var augments: Array[BaseAugment] = []  # applied upgrades, shown as icons above the card
var max_augments := 1  # raise for cards that say they hold more


## units[i], cells[i], rotations[i] = the grid, cell and rotation chosen for grid_actions[i], in order.
## Runs every grid action at its own cell and returns hits[i], the cells grid_actions[i] changed.
## Override and call super() to add other actions, e.g. one that depends on the hits.
func execute(combat: CombatState, units: Array[CombatUnit], cells: Array[Vector2i], rotations: Array[int])->Array:
	var hits := []
	for i in grid_actions.size():
		hits.append(await grid_actions[i].execute(combat, units[i], cells[i], rotations[i]))
	return hits


func get_description() -> String:
	return description
