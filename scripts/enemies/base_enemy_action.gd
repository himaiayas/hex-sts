@abstract class_name BaseEnemyAction extends RefCounted

## An enemy move made of parts (see EnemyActionPart). Each part targets the player's grid
## or the enemy's own grid, so one action can attack, shield itself, or both.
## plan() locks the target cells (the intent); execute() uses exactly those cells.

var action_type: Enum.BaseEnemyActionEnum # used to determine the intent graphic, init in subclass
var action_name: String # Apply for some big action, like "Cyborg uses 'NeoArmstrongCycloneJetArmstrongCannon'!"
var probability: float # init in BaseEnemy (when instancing the action)
var parts: Array[EnemyActionPart] = [] # set in subclass _init()
var pose: Texture2D # optional, shown on the enemy while it attacks
var hit_vfx: Texture2D # optional, faded over the target's grid when the hit lands


func _init(_action_type: Enum.BaseEnemyActionEnum,_action_name: String, _probability: float) -> void:
    action_type = _action_type
    action_name = _action_name
    probability = _probability


## Called at the start of the player's turn: choose a cell for every part.
func plan(combat: CombatState, owner: CombatUnit) -> void:
    for part in parts:
        part.cell = pick_cell(part, target_of(part, combat, owner))


## Called on the enemy's turn: run every part on the cells chosen in plan(). Await the grid actions.
@abstract func execute(combat: CombatState, owner: CombatUnit) -> void

func target_of(part: EnemyActionPart, combat: CombatState, owner: CombatUnit) -> CombatUnit:
    return combat.player if part.side == Enum.Side.PLAYER else owner


## Default: the cell where the pattern scores highest, ties broken randomly.
## Override for scripted or random targeting.
func pick_cell(part: EnemyActionPart, target: CombatUnit) -> Vector2i:
    var candidates := {}
    for cell in target.health:
        for t in part.tiles:
            candidates[cell - t.coords] = true
    var best: Array[Vector2i] = []
    var best_score := -1
    for cell: Vector2i in candidates:
        var score := score_cell(part, cell, target)
        if score > best_score:
            best_score = score
            best = [cell]
        elif score == best_score:
            best.append(cell)
    return best.pick_random() if not best.is_empty() else Vector2i.ZERO


## Damage: undamaged = 2, shielded = 1, +1 if plated (it would shield again). Shield: undamaged = 1.
## Plate: undamaged without Plate = 1. Other tiles on the grid = 1.
func score_cell(part: EnemyActionPart, cell: Vector2i, target: CombatUnit) -> int:
    var score := 0
    for t in part.tiles:
        var tile: HealthTile = target.health.get(cell + t.coords)
        if tile == null:
            continue
        if t is DamageTile:
            if tile.hp >= Enum.HealthTileEnum.SHIELDED:
                score += 1
            elif tile.hp == Enum.HealthTileEnum.UNDAMAGED:
                score += 2
            if tile.has_effect(PlateTileEffect):
                score += 1
        elif t is ShieldTile:
            if tile.hp == Enum.HealthTileEnum.UNDAMAGED:
                score += 1
        elif t is ApplyEffectTile and t.effect is PlateTileEffect:
            if tile.hp > Enum.HealthTileEnum.DAMAGED and not tile.has_effect(PlateTileEffect):
                score += 1
        else:
            score += 1
    return score


## A random cell where the part covers at least one tile that isn't damaged, for scattered hits.
## Cells that cover more of them are more likely.
func pick_random_cell(part: EnemyActionPart, target: CombatUnit) -> Vector2i:
    var cells: Array[Vector2i] = []
    for cell in target.health:
        if target.health[cell].hp > Enum.HealthTileEnum.DAMAGED:
            for t in part.tiles:
                cells.append(cell - t.coords)
    return cells.pick_random() if not cells.is_empty() else Vector2i.ZERO


## Inflicts tile on amount random tiles of the owner's own grid that it can change (heal, shield).
## Picked when the move runs, so it uses the grid as the player's turn left it.
func inflict_random_own(combat: CombatState, owner: CombatUnit, tile: BaseActionTile, amount: int) -> void:
    var cells: Array = owner.health.keys().filter(func(c: Vector2i) -> bool: return tile.can_inflict(owner, c))
    cells.shuffle()
    for cell in cells.slice(0, amount):
        tile.inflict(combat, owner, cell)
    await combat.flush()
