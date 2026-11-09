@abstract class_name BaseEnemyAction extends RefCounted

## An enemy move made of parts (see EnemyActionPart). Each part targets the player's grid
## or the enemy's own grid, so one action can attack, shield itself, or both.
## plan() locks the target cells (the intent); execute() uses exactly those cells.

const SCATTER_MIN := 0.75 # a scattered hit covers at least this share of the most open tiles it could

var action_type: Enum.BaseEnemyActionEnum # used to determine the intent graphic, init in subclass
var action_name: String # Apply for some big action, like "Cyborg uses 'NeoArmstrongCycloneJetArmstrongCannon'!"
var description: String # a short line on what the move does, set in subclass _init()
var probability: float # init in BaseEnemy (when instancing the action)
var parts: Array[EnemyActionPart] = [] # set in subclass _init()
var pose: Texture2D # optional, shown on the enemy while it attacks
var hit_vfx: Texture2D # optional, faded over the target's grid when the hit lands
var ripple_vfx: Texture2D # optional, one ring that ripples out from the enemy, under the arena, when the move changes its grid
var aim_vfx: Texture2D # optional, a sight drifting over the player's sprite while the move is in the intent
var projectile_vfx: Texture2D # optional, flies left from the enemy's sprite to the player's before the hit lands
var heavy_impact := false # a boss's big move: plays a heavy layered impact sound when it lands (Sfx boss_boom + boss_crash)
var extra_types: Array[Enum.BaseEnemyActionEnum] = [] # a combo move's other types, each one more icon in its intent row
var intent_icon: Texture2D # optional, replaces action_type's icon (Summon, Stunned)

## Icons in an intent row go in this order: what hits the player first, then what the enemy does to itself.
const TYPE_ORDER: Array[Enum.BaseEnemyActionEnum] = [
    Enum.BaseEnemyActionEnum.ATTACK,
    Enum.BaseEnemyActionEnum.DEBUFF,
    Enum.BaseEnemyActionEnum.DEFEND,
    Enum.BaseEnemyActionEnum.BUFF,
    Enum.BaseEnemyActionEnum.WIND_UP,
]
const TYPE_ICONS := {
    Enum.BaseEnemyActionEnum.ATTACK: preload("res://assets/grid_effects/damage.png"),
    Enum.BaseEnemyActionEnum.DEBUFF: preload("res://assets/icons/intent_debuff.png"),
    Enum.BaseEnemyActionEnum.DEFEND: preload("res://assets/icons/intent_defend.png"),
    Enum.BaseEnemyActionEnum.BUFF: preload("res://assets/icons/intent_buff.png"),
    Enum.BaseEnemyActionEnum.WIND_UP: preload("res://assets/icons/intent_wind_up.png"),
}


func _init(_action_type: Enum.BaseEnemyActionEnum,_action_name: String, _probability: float) -> void:
    action_type = _action_type
    action_name = _action_name
    probability = _probability


## Its row in the intent label.
func intent_text() -> String:
    return action_name


## One icon per type (action_type and extra_types), in TYPE_ORDER; intent_icon replaces action_type's.
func intent_icons() -> Array[Texture2D]:
    var icons: Array[Texture2D] = []
    for type in TYPE_ORDER:
        if type == action_type and intent_icon:
            icons.append(intent_icon)
        elif type == action_type or type in extra_types:
            icons.append(TYPE_ICONS[type])
    return icons


## Attacks only: the Damage tiles of each part aimed at the player, "3x2" when the parts match, else "10+6".
func hit_text() -> String:
    if action_type != Enum.BaseEnemyActionEnum.ATTACK:
        return ""
    var counts: Array[int] = []
    for part in parts:
        if part.side == Enum.Side.PLAYER:
            counts.append(part.tiles.filter(func(t: BaseActionTile) -> bool: return t is DamageTile).size())
    if counts.is_empty():
        return ""
    if counts.size() > 1 and counts.count(counts[0]) == counts.size():
        return "%dx%d" % [counts[0], counts.size()]
    return "+".join(PackedStringArray(counts.map(func(n: int) -> String: return str(n))))


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


## Damage: undamaged = 2, shielded = 1 (2 with Pierce), +1 if plated (it would shield again).
## Shield: undamaged = 1. Plate: undamaged without Plate = 1. Other tiles on the grid = 1.
func score_cell(part: EnemyActionPart, cell: Vector2i, target: CombatUnit) -> int:
    var score := 0
    for t in part.tiles:
        var tile: HealthTile = target.health.get(cell + t.coords)
        if tile == null:
            continue
        if t is DamageTile:
            if tile.hp == Enum.HealthTileEnum.SHIELDED and not t.pierce:
                score += 1
            elif tile.hp > Enum.HealthTileEnum.DAMAGED:
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
## Tiles the earlier parts of this move will damage don't count (a Shield there only breaks),
## so every hit lands on something. Only cells covering at least SCATTER_MIN of the best count
## are picked, so a hit never lands on a poor spot.
func pick_random_cell(part: EnemyActionPart, target: CombatUnit) -> Vector2i:
    var taken := {}
    for earlier: EnemyActionPart in parts.slice(0, parts.find(part)):
        for t in earlier.tiles:
            var c: Vector2i = earlier.cell + t.coords
            if target.health.has(c) and target.health[c].hp != Enum.HealthTileEnum.SHIELDED:
                taken[c] = true
    var open := {} # cell -> open tiles the part covers there
    for cell in target.health:
        if target.health[cell].hp > Enum.HealthTileEnum.DAMAGED and not taken.has(cell):
            for t in part.tiles:
                open[cell - t.coords] = open.get(cell - t.coords, 0) + 1
    if open.is_empty():
        return Vector2i.ZERO
    var least: float = open.values().max() * SCATTER_MIN
    return open.keys().filter(func(c: Vector2i) -> bool: return open[c] >= least).pick_random()


## Inflicts tile on amount random tiles of the owner's own grid that it can change (heal, shield).
## Picked when the move runs, so it uses the grid as the player's turn left it.
func inflict_random_own(combat: CombatState, owner: CombatUnit, tile: BaseActionTile, amount: int) -> void:
    var cells: Array = owner.health.keys().filter(func(c: Vector2i) -> bool: return tile.can_inflict(owner, c))
    cells.shuffle()
    for cell in cells.slice(0, amount):
        tile.inflict(combat, owner, cell)
    await combat.flush()
