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
## Shields or heals this move puts on some of its own tiles, as [tile script, amount] (ShieldTile,
## HealTile): add_own_effect() in _init. plan_own() picks those tiles when the intent is planned,
## so they show on the enemy's grid and as intent icons; inflict_random_own() then uses them.
## Kept apart from parts, which many moves run against the player.
var own_effects: Array = []
var _own_parts := {}  # tile script -> the SELF part of its planned tiles
## Turns until this move's damage lands: 0 = this turn. A wind-up (EnemyWindUp, Ramiel's Charge)
## shows where a later attack will hit; its damage tiles then show the charge icon, not damage.
var lands_in := 0
var heavy_impact := false # a boss's big move: plays a heavy layered impact sound when it lands (Sfx boss_boom + boss_crash)


func _init(_action_type: Enum.BaseEnemyActionEnum,_action_name: String, _probability: float) -> void:
    action_type = _action_type
    action_name = _action_name
    probability = _probability


## Intent icons above the enemy's head, in this order. INTENT_ICONS has each kind's image.
const INTENT_ORDER: Array[String] = ["damage", "charge", "debuff", "defence", "heal", "buff"]
const INTENT_ICONS := {
    damage = preload("res://assets/icons/enemy_damage.png"),
    charge = preload("res://assets/icons/enemy_charge_damage.png"),  # damage that lands in delay() turns
    debuff = preload("res://assets/icons/enemy_debuff.png"),
    defence = preload("res://assets/icons/enemy_defence.png"),
    heal = preload("res://assets/icons/enemy_heal.png"),
    buff = preload("res://assets/icons/enemy_buff.png"),
}
const TYPE_INTENTS := {
    Enum.BaseEnemyActionEnum.ATTACK: "damage",
    Enum.BaseEnemyActionEnum.DEFEND: "defence",
    Enum.BaseEnemyActionEnum.BUFF: "buff",
    Enum.BaseEnemyActionEnum.DEBUFF: "debuff",
}


func add_own_effect(tile_script: Script, amount: int) -> void:
    own_effects.append([tile_script, amount])


## Picks the tiles each own effect will go on (BaseEnemy.plan calls it after plan()).
func plan_own(owner: CombatUnit) -> void:
    for effect: Array in own_effects:
        var script: Script = effect[0]
        var probe: BaseActionTile = script.new(Vector2i.ZERO)
        var cells: Array = owner.health.keys().filter(func(c: Vector2i) -> bool: return probe.can_inflict(owner, c))
        cells.shuffle()
        var tiles: Array[BaseActionTile] = []
        for cell: Vector2i in cells.slice(0, effect[1]):
            tiles.append(script.new(cell))
        var part: EnemyActionPart = _own_parts.get(script)
        if part == null:
            part = EnemyActionPart.new(Enum.Side.SELF, tiles)
            _own_parts[script] = part
        part.cell = Vector2i.ZERO
        part.tiles = tiles


## The planned own-effect parts (on its own grid, cell ZERO, tiles at their cells).
func own_parts() -> Array:
    return _own_parts.values()


## Turns until its damage lands (lands_in; overridden where it counts down, like Ramiel's Charge).
func delay() -> int:
    return lands_in


## What this move does, as INTENT_ORDER kinds: its action_type, plus whatever its parts do
## (damage or a debuff on the player; a shield, heal or buff on itself). An attack that also
## shields the enemy shows both.
func intent_kinds() -> Array[String]:
    # A wind-up does nothing now, so its type (BUFF) doesn't get an icon; its aimed damage shows as charge.
    var kinds := {} if delay() > 0 else {TYPE_INTENTS[action_type]: true}
    for part in parts + own_parts():
        for t in part.tiles:
            var effect: BaseEffect = (t as ApplyEffectTile).effect if t is ApplyEffectTile else null
            var debuff := effect is BaseTileEffect and (effect as BaseTileEffect).debuff
            if part.side == Enum.Side.PLAYER:
                if t is DamageTile:
                    kinds["charge" if delay() > 0 else "damage"] = true
                elif debuff or t is ShredTile:
                    kinds.debuff = true
            elif t is ShieldTile or effect is PlateTileEffect:
                kinds.defence = true
            elif t is HealTile:
                kinds.heal = true
            elif (effect and not debuff) or t is CleanseTile:
                kinds.buff = true
    for effect: Array in own_effects:  # even with nothing to plan on yet (a heal at full health)
        if effect[0] == ShieldTile:
            kinds.defence = true
        elif effect[0] == HealTile:
            kinds.heal = true
    var result: Array[String] = []
    for kind in INTENT_ORDER:
        if kinds.has(kind):
            result.append(kind)
    return result


## Its row in the intent label.
func intent_text() -> String:
    return action_name


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
## amount of its own tiles get tile: the ones plan_own() picked first (the intent shown), then, if some
## can't take it any more (the player damaged one picked for a Shield), random others.
func inflict_random_own(combat: CombatState, owner: CombatUnit, tile: BaseActionTile, amount: int) -> void:
    var valid := func(c: Vector2i) -> bool: return tile.can_inflict(owner, c)
    var cells: Array = []
    var part: EnemyActionPart = _own_parts.get(tile.get_script())
    if part:
        cells = part.tiles.map(func(t: BaseActionTile) -> Vector2i: return t.coords).filter(valid)
    var others: Array = owner.health.keys().filter(func(c: Vector2i) -> bool: return valid.call(c) and c not in cells)
    others.shuffle()
    cells.append_array(others)
    for cell in cells.slice(0, amount):
        tile.inflict(combat, owner, cell)
    await combat.flush()
