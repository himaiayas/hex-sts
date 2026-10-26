# Remaining Tasks

## Combat

### 0. Settle the health matrix indexing

- **Requirement/Prereq:** None
- **Brief Description:** `CombatUnit` indexes `health[coords.x][coords.y]`, which only works with non-negative indices. Decide the convention: either matrix index = axial coords (as now), or store an offset (e.g. `+radius`) so negative axial coords work. `HealthGridView` and `has_health_tile()` must follow the same rule.
- [x] Done ✅: Health is now a `Dictionary[Vector2i, HealthTile]` keyed by axial coords, so negative coords work without an offset. `has_health_tile()` is gone; everything checks `unit.health.has(cell)`.

### 1. Card Fan

- **Requirement/Prereq:** -
- **Brief Description:** Cards in hand should be fan as an arc of a circle. When hover a card, it should enlarges and shows the whole detail of card.
- [x] Done ✅: `HandView` (`scripts/combat/ui/hand_view.gd`) lays cards on an arc, and spacing shrinks for big hands. Hover straightens, enlarges and lifts the card and pushes its neighbours aside. The selected card gets a blue border and bobs gently. Cards ease into place instead of snapping. The targeting arrow and draw/discard animations are not done yet.

### 2. Card Rendering

- **Requirement/Prereq:** -
- **Brief Description:**
  - A card has one tile pattern (`tiles: Array[BaseActionTile]`) but can run several actions, e.g. "deal [3 tiles] and draw 2". Extra actions go in the card's `execute`.
  - description property in BaseCard should have a format to render hex (e.g. "{render}\nDraw 1\nGain 1 {keyword:Strength}") means
  - Line 1: Render the card's tiles.
  - Line 2: Print "Draw 1".
  - Line 3: Print "Gain 1 Strength", but Strength is a keyword, it should be bold and show tooltips.
  - If the rendered hexes are too large, reduce the size.
- [x] Done ✅: A line that is exactly `{render}` draws the pattern with `PatternView`: hexes shrink to fit a 124×28 box, and the (0,0) hex, where the cursor goes, is outlined. Other lines are rich text, and `{keyword:X}` shows as bold gold. Keyword definitions come from the matching `BaseEffect` (`Keywords.describe`), so a new effect needs no registration. They show as panels beside the hovered or selected card after 0.5s. The text area fits about 2 lines under one pattern before the card grows past 190px.

### 3. Combat end

- **Requirement/Prereq:** -
- **Brief Description:** Implement `CombatUnit.is_dead()`, call `RunState.end_combat()`. Connect with post-combat reward.

### 4. Rotating Pattern

- **Brief Description**
  - Only when selecting a card, the grid pattern is rotateable. Add Input Listener when player click [E] or scroll mouse down for clockwise rotate. click [q] or scroll mouse up for anti-clockwise rotate. Each click rotates by 60 degree.
  - Axial coords shall be changed from (q,r) to (-r, q+r) for clockwise, and to (q+r, -q) for anticlockwise. For Dictionary, you have to create new Dict.
  - Do not change the axial coords of the tiles in card itself. Only change temporary dict.

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
  - Conditional actions: e.g. "deal [3 tiles]. If this damaged fewer than 2 enemy tiles, gain a random shield tile". `GridAction.execute` needs to report what it hit, and the condition lives in the card's `execute`.
  - Random tile actions: e.g. "shield a random tile on your grid". The target cell is picked at play time, so it can't be drawn with `{render}`.

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
- [x] Done ✅: Same as #2.

## UI

### 15. Hand

- **Requirement/Prereq:** None
- **Brief Description:** Hand as fan shape. Hover to upsize.
- [x] Done ✅: Same as #1.

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
