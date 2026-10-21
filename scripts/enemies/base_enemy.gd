@abstract class_name BaseEnemy
extends CombatUnit

## Subclasses set name, health shape, sprite and actions in _init().
## plan() picks the intent at the start of the player's turn; take_turn() executes it (locked).

var sprite: Texture2D
var actions: Array[BaseAction] = []  # looped in order
var intent_action: BaseAction
var intent_cell: Vector2i

var _next := 0


func plan(player: CombatUnit) -> void:
	intent_action = _choose_next()
	intent_cell = pick_target_cell(intent_action, player)


func take_turn(combat: CombatState) -> void:
	if intent_action == null:
		return
	intent_action.execute(ActionContext.new(combat, self, combat.player, intent_cell))
	intent_action = null


## Strict loop. Override for random or scripted patterns.
func _choose_next() -> BaseAction:
	var action := actions[_next]
	_next = (_next + 1) % actions.size()
	return action


## Greedy: the cell where the pattern scores highest, ties broken randomly.
## Candidates are every cell where at least one tile lands on the target's grid.
func pick_target_cell(action: BaseAction, target: CombatUnit) -> Vector2i:
	var grid_action := action as GridAction
	if grid_action == null:
		return Vector2i.ZERO
	var candidates := {}
	for cell in target.health:
		for t in grid_action.tiles:
			candidates[cell - t.coords - grid_action.anchor] = true
	var best: Array[Vector2i] = []
	var best_score := -1
	for cell: Vector2i in candidates:
		var score := _score_cell(grid_action, cell, target)
		if score > best_score:
			best_score = score
			best = [cell]
		elif score == best_score:
			best.append(cell)
	return best.pick_random()


## Damage on undamaged = 2, on shielded = 1, on damaged = 0. Other tiles score 0 for now.
func _score_cell(action: GridAction, cell: Vector2i, target: CombatUnit) -> int:
	var score := 0
	for t in action.tiles:
		var tile: HealthTile = target.health.get(cell + t.coords + action.anchor)
		if tile == null or not t is DamageTile:
			continue
		if tile.hp >= HealthTile.HealthTileEnum.SHIELDED:
			score += 1
		elif tile.hp == HealthTile.HealthTileEnum.UNDAMAGED:
			score += 2
	return score


static func make_move(move_name: String, tiles: Array[BaseActionTile]) -> GridAction:
	var action := GridAction.new(BaseAction.TargetType.PLAYER, tiles)
	action.display_name = move_name
	return action
