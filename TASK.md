# Remaining Tasks

## Combat

### 0. Settle the health matrix indexing

- **Requirement/Prereq:** None
- **Brief Description:** `CombatUnit` indexes `health[coords.x][coords.y]`, which only works with non-negative indices. Decide the convention: either matrix index = axial coords (as now), or store an offset (e.g. `+radius`) so negative axial coords work. `HealthGridView` and `has_health_tile()` must follow the same rule.
- [x] Done ✅: Health is now a `Dictionary[Vector2i, HealthTile]` keyed by axial coords, so negative coords work without an offset. `has_health_tile()` is gone; everything checks `unit.health.has(cell)`.

### 1. Card Fan

- **Requirement/Prereq:** -
- **Brief Description:** Cards in hand should be fan as an arc of a circle. When hover a card, it should enlarges and shows the whole detail of card.

### 2. Card Rendering

- **Requirement/Prereq:** -
- **Brief Description:**
  - `BaseCard` contain property `tiles` which is used in `GridAction`. Chnage it to Array of Array of Tile, so that we can afford multiple `GridAction` in one card
  - description property in BaseCard should have a format to render hex (e.g. "{render:0}\nDraw 1\nGain 1 {keyword:Strength}) means
    - Line 1: Render tiles[0].
	- Line 2: Print "Draw 1".
	- Line 3: Print "Gain 1 Strength", but Strength is a keyword, it should be bold and show tooltips.
      You can think of any format.
  - If the rendered hexes are too large, reduce the size.

### 3. Combat end

- **Requirement/Prereq:** -
- **Brief Description:** Implement `CombatUnit.is_dead()`, call `RunState.end_combat()`. Connect with post-combat reward.

### 4. Card target type

- **Requirement/Prereq:** -
- **Brief Description:** `BaseAction.TargetType` (PLAYER/ENEMY) isn't used. Some cards can target player themself (e.g.Shield)

### 5. Tile pattern rotation

- **Requirement/Prereq:** 1
- **Brief Description:** Rotate a card's tile pattern in 60deg. Apply it to both the preview and `GridAction.execute`.

### 6. Tile statuses

- **Requirement/Prereq:** -
- **Brief Description:** Design `BaseTileStatus` (e.g. poison). Implement `StatusTile.inflict` to call `apply_status_health_tile`

### 7. Power

- **Requirement/Prereq:** -
- **Brief Description:** Implement `BaseStatus`

### 8 Event

- **Requirement/Prereq:** ?
- **Brief Description:** Somehow make trigger such as On_turn_start or on_tile_damage work. Should be able to both global and tile-wise.

### 9. Remaining Action

- **Requirement/Prereq:** 6
- **Brief Description:** Apply status effect & draw & gain energy & etc

## Enemies

### 10. Enemy Class

- **Requirement/Prereq:** 1, 2
- **Brief Description:** Enemy classes implemented with Polymorphism concept of OOP: name, health grid shape, sprite, and a list of actions/pattern.

### 11. Enemy turn and AI

- **Requirement/Prereq:** 10
- **Brief Description:** Run enemy actions in `CombatState.end_turn()` with the same action/tile classes (`execute(combat, unit, cell)`).

### 12. Enemy intents

- **Requirement/Prereq:** 10 / UI design
- **Brief Description:** Choose the next action ahead of time and show it on screen

## Cards and content

### 13. More cards

- **Requirement/Prereq:** 8, 9
- **Brief Description:** Defend, draw cards, status cards, and multi-tile / row patterns (`LineGridAction`-style computed shapes).

### 14. Card descriptions

- **Requirement/Prereq:** None
- **Brief Description:** (`get_description()`) should contain description format that allow rendering symbol or tile patterns in the card.

## UI

### 15. Hand

- **Requirement/Prereq:** None
- **Brief Description:** Hand as fan shape. Hover to upsize.

### 16. Hover Health Grid

- **Requirement/Prereq:** UI design
- **Brief Description:** Hover on health grid while selecting card show flashing/pulsing effect idk.

## Main menu and Setting

### 17. Main menu to Map

- **Requirement/Prereq:** -
- **Brief Description:** Main menu ui, click start to change the game state to map

## Out-Of-Combat

### 18. Run map

- **Requirement/Prereq:** UI design
- **Out-of-combat-gameplay:** The rooms will also be hexagonal. Start each floor as one empty room with some directions connected to `unexplored rooms`. Player have limit number of **Steps**. When player pass a room, they lose 1 step. Once they run out of steps, they fight the floor boss. When enetr `unexplored room`, they have 2-3 choice of room to make it be. Each room presented in the choices contain info Room Type and Doors.
- **PCG:** In general, we want to punish player going full straight and not make connect room. What we have talked is that, we give more weight to dead-end room if player do that, so player have to waste step to head back
- **?:** Havent decide whether we will do vertical hex or horizontal hex. It will affects the matrix that representing axial coordinate.
- **Brief Description:** Out-of-combat map with rooms (fight, elite, rest, shop, boss) that reads and writes `RunState`. Develop PCG for choices of room. Click room to enter scene of that room. This task is so fucking huge. I might divide it.

### 19. Game Logic for other Rooms

- **Requirement/Prereq:** 18
- **Brief Description:** Other room e.g. Shop / Chest / ? idk

### 20. Save / load

- **Requirement/Prereq:** everything
- **Brief Description:** Serialize run state.

## Spotted Problems by Claude

- ~~**Hover sentinel collides with a real cell:**~~ Fixed: `NO_CELL` is now `Vector2i(999999, 999999)`.
- **Dead units still act (#3):** enemies now take turns (`BaseEnemy.take_turn`) even when every tile is damaged, and the player can reach 0 undamaged tiles with nothing happening. Needs `is_dead()` + checks in `CombatState.end_turn()`.
- **Shield stacks forever:** `CombatUnit.shield_health_tile` does `hp + 1` with no cap (2 → 3 → 4...). The view treats `>= SHIELDED` as shielded, so it's hidden.
- ~~**Target type ignored (see #4):**~~ Partly fixed: `BaseCard.target` (default ENEMY) decides which grid a card is played on; `ShieldEnemy` became `ShieldPlayer` and shields your own grid. `BaseAction.target` is still unused.
- **Shared effect instance:** each card creates one `PoisonTileEffect` and every tile it hits gets that same object. `card.duplicate()` is shallow, so all copies of the card share it too. Per-tile stacks/duration will break; create or duplicate the effect in `apply_effect_health_tile`.
- **Orphan `.uid` files** left from the status→effect rename: `scripts/effects/base_status.gd.uid`, `scripts/effects/tile_effects/base_tile_status.gd.uid`, `scripts/effects/tile_effects/poison_tile_status.gd.uid`.
- ~~**Mixed indentation:**~~ Fixed in `be87566`: all `.gd` files now use tabs (Godot's default, applied on save), and `.editorconfig` enforces it.
- **Stale comments:** `HealthTile.hp` still says `-1 = empty`; `make_hex_health` says "hexagon of radius r in a (2r+1)x(2r+1) matrix" but takes a coord list and returns a Dictionary.
- **Main scene is a dead end:** `mainmenu.tscn` is the main scene, but its button has no script. Combat has to be run directly (F6 on `combat.tscn`).
- **Content placeholders:** `StatusStrike` costs 3 (all your energy), card descriptions are `"fdksmfdf."`, and `scripts/main.gd` is the empty template.
- **TASK.md drift:** #6 mentions `StatusTile`/`BaseTileStatus`, which are now `ApplyEffectTile`/`BaseTileEffect`.
