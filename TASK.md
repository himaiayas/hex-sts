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
  - A card holds `grid_actions: Array[GridAction]`, one distinct tile pattern each (e.g. poison 1 tile, then attack 3 straight tiles). Other actions (e.g. draw 2) go in the card's `execute` after `super()`.
  - description property in BaseCard should have a format to render hex (e.g. "{render:0}\nDraw 1\nGain 1 {keyword:Strength}") means
  - Line 1: Render grid_actions[0].
  - Line 2: Print "Draw 1".
  - Line 3: Print "Gain 1 Strength", but Strength is a keyword, it should be bold and show tooltips.
  - If the rendered hexes are too large, reduce the size.
- [x] Done ✅: A line that is exactly `{render:N}` draws `grid_actions[N]` with `PatternView`, including its `anchor`: hexes shrink to fit a 124×28 box, and the (0,0) hex, where the cursor goes, is outlined. Each grid action gets its own click, in order, and its own target side (`GridAction.target`). `BaseCard.execute` then runs them all, so simple cards only set data. Other lines are rich text, and `{keyword:X}` shows as bold gold. Keyword definitions come from the matching `BaseEffect` (`Keywords.describe`), so a new effect needs no registration. They show as panels beside the hovered or selected card after 0.5s. The text area fits about 2 lines under one pattern before the card grows past 190px, so a card with two patterns is too tall for now.

### 3. Combat end

- **Requirement/Prereq:** -
- **Brief Description:** Implement `CombatUnit.is_dead()`, call `RunState.end_combat()`. Connect with post-combat reward.
- [x] Done ✅: By Mai. `CombatState.is_won()` / `is_lost()` use `is_dead()`, and `combat_scene` calls `RunState.end_combat()` and shows the reward or defeat panel. Dead enemies skip their turn.

### 4. Rotating Pattern

- **Brief Description**
  - Only when selecting a card, the grid pattern is rotateable. Add Input Listener when player click [E] or scroll mouse down for clockwise rotate. click [q] or scroll mouse up for anti-clockwise rotate. Each click rotates by 60 degree.
  - Axial coords shall be changed from (q,r) to (-r, q+r) for clockwise, and to (q+r, -q) for anticlockwise. For Dictionary, you have to create new Dict.
  - Do not change the axial coords of the tiles in card itself. Only change temporary dict.
- [x] Done ✅: `GridAction.rotated(steps)` returns a new offset -> tile dict, turning `coords + anchor` around the clicked cell, so the card's tiles never change. While a card is selected, E / wheel down rotates clockwise and Q / wheel up anticlockwise (physical keys, so Thai layout works). Each click remembers its own rotation, the next grid action starts from the current one, and deselecting resets it. Check: `rotation_check.gd` (headless).

### 5. Tile pattern rotation

- **Requirement/Prereq:** 1
- **Brief Description:** Rotate a card's tile pattern in 60deg. Apply it to both the preview and `GridAction.execute`.
- [x] Done ✅: Same as #4. The preview, the flickering placed patterns and `GridAction.execute` all use the same rotated dict. Enemies call `execute` without a rotation and get 0.

### 6. Tile statuses

- **Requirement/Prereq:** -
- **Brief Description:** Design `BaseTileEffect` (e.g. poison). Implement `ApplyEffectTile.inflict` to call `apply_effect_health_tile`
- [x] Done ✅: Rules are in `KEYWORDS.md` (decided in issue #8). Shield stays hard-coded (`hp == SHIELDED`). New `PlateTileEffect` shields its tile at the start of its owner's turn unless the opponent attacked it during their turn, and goes away when the tile is damaged. Slime Harden and Guarded Bash use Plate, and enemy attacks score Plated hexes +1. Effects fire in `order`, so Poison goes before Plate. No tile effect goes on a damaged hex. Shield / Exhaust / Retain / Sacrifice tooltips come from `Keywords.NOT_EFFECTS`. Check: `effect_check.gd` (headless).

### 7. Power

- **Requirement/Prereq:** -
- **Brief Description:** Implement `BaseStatus`
- [x] Done ✅: Named `BasePower` (an `amount` of stacks; applying it again adds them) to match `add_power` / `ApplyPowerAction`. `StrengthPower`: each attack also damages that many random tiles next to the cells its damage tiles landed on (per action, not per tile; not on cells it already landed on; a shield absorbs an extra as usual; only on the other side's grids), from every `GridAction` / `RandomGridAction` / `RandomTileAction` (extras don't spread again, and count as hits). It uses the Strength of `CombatState.acting_unit()`, so enemies can have it too. Powers show as badges with their stacks under the grid, with a tooltip on hover (`icon.svg` placeholder until they get art). New power card Enhance (Gain 1 Strength); power cards go to no pile after they're played. Check: `action_check.gd`.

### 8 Event

- **Requirement/Prereq:** ?
- **Brief Description:** Somehow make trigger such as On_turn_start or on_tile_damage work. Should be able to both global and tile-wise.
- [x] Done ✅: Mai's `on_trigger(Enum.Trigger, ...)` on effects, powers and artifacts, fired by `CombatUnit.fire` / `fire_at`. Added `CombatUnit.in_turn` so an effect can tell whose turn it is, and put back `BaseEffect.tick()`, which was removed while `CombatUnit` still called it, so effects never ran out.

### 9. Remaining Action

- **Requirement/Prereq:** 6
- **Brief Description:** Apply status effect & draw & gain energy & etc
  - Conditional actions: e.g. "deal [3 tiles]. If this damaged fewer than 2 enemy tiles, gain a random shield tile". `GridAction.execute` needs to report what it hit, and the condition lives in the card's `execute`.
  - Random tile actions: e.g. "shield a random tile on your grid". The target cell is picked at play time, so it can't be drawn with `{render}`.
- [x] Done ✅: `inflict`, `GridAction.execute` and `BaseAction.execute` report the cells they changed (a shield block isn't a hit), and `BaseCard.execute` returns them per grid action, so a card checks `super()`'s result for conditions. New `GainEnergyAction` (not capped by `max_energy`), `RandomTileAction` (random tiles from one pool: your grid, or every living enemy) and `RandomGridAction` (random tiles on the grid you click; every grid it can go on flickers while selected). `can_inflict` keeps random picks off tiles they can't change. Cards with no grid actions are cast by dragging them to the middle of the screen. Example cards Thrust, Divine Mercy, Rapid Fire and Arrow Rain are in the pool and, for testing, the starting deck. Check: `action_check.gd` (headless).

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

- ~~**Aiming at damaged tiles:**~~ Fixed: the player can't aim a grid action at a damaged tile (`GridAction.can_aim`, checked on click and in `play_card`), and there's no preview there. Rapid Fire can still pick a grid by any of its tiles. Enemies aren't restricted; their pattern scoring already avoids damaged tiles.
- ~~**Hover sentinel collides with a real cell:**~~ Fixed: `NO_CELL` is now `Vector2i(999999, 999999)`.
- ~~**Dead units still act (#3):**~~ Fixed by Mai in #3. Was: enemies now take turns (`BaseEnemy.take_turn`) even when every tile is damaged, and the player can reach 0 undamaged tiles with nothing happening. Needs `is_dead()` + checks in `CombatState.end_turn()`.
- ~~**Target type ignored (see #4):**~~ Partly fixed: `BaseCard.target` (default ENEMY) decides which grid a card is played on; `ShieldEnemy` became `ShieldPlayer` and shields your own grid. `BaseAction.target` is only used by `RandomTileAction`.
- ~~**Mixed indentation:**~~ Fixed in `be87566`: all `.gd` files now use tabs (Godot's default, applied on save), and `.editorconfig` enforces it.
- ~~**Stale comments:**~~ Fixed: `HealthTile.hp` no longer says `-1 = empty`, and `make_hex_health`'s comment matches what it does.
- **Main scene is a dead end:** `mainmenu.tscn` is the main scene, but its button has no script. Combat has to be run directly (F6 on `combat.tscn`).
- **Content placeholders:** `StatusStrike` costs 3 (all your energy), card descriptions are `"fdksmfdf."`, and `scripts/main.gd` is the empty template.
