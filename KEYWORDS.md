# Keywords

English translation of the **Keywords** tab of the design sheet
(https://docs.google.com/spreadsheets/d/1ka0HmraZKJdy5WNRn9CmD43_94UFQQe9Yh29IsCXNtU, tab "Keywords").
⚙️ marks a rule clarification that was already in the sheet. The examples come from the sheet's Card and Monster tabs.
The last two sections, "Decided" and "For Mai", are not from the sheet. They say how the keywords map to our code.

## Core rules
| Keyword | Meaning |
|---|---|
| HP / Hex | HP is the hexes on the player's board. 1 hex = 1 HP. A hex that gets hit is destroyed (lost). |
| Deal X | Attack the enemy for X damage. The player places the card's pattern (the sheet's Image column) on the enemy board, and every hex it covers deals 1 damage. |
| Hit X | (Enemy side) The enemy hits X player hexes with the pattern shown in its intent. Each hit hex that has no protection is destroyed. |
| Intent | The enemy shows its next action ahead of time (type, pattern, position) so the player can plan a defence. |
| Energy | Pays for cards. You get 3 at the start of each turn, and energy you don't spend doesn't carry over. |
| Cost X | An X-cost card spends all remaining energy, and its value scales with the amount spent (e.g. Whirlwind). |
| Draw X | Draw X more cards from the draw pile. If the draw pile is empty, shuffle the discard pile back in. |
| Discard | Move a card from hand to the discard pile. It comes back when the pile is reshuffled. |
| Heal X | Restore X lost hexes. The player chooses which ones. You can't heal above your full hex count. |

## Card types
| Type | How it plays |
|---|---|
| Attack | Hits the enemy with a pattern. Affected by Edge. |
| Defense | Places protection (Block / Plate) on your own hexes. |
| Skill | General effects such as draw, energy, Retaliate, or status changes. Goes to the discard pile after it's played. |
| Power | Played once and lasts for the whole combat. Doesn't go back to the discard pile. |

## Player keywords
| Keyword | Meaning | Example cards |
|---|---|---|
| Block X | Covers X of your own hexes and protects against hits that land on them. It expires at the start of your next turn. ⚙️ Block doesn't break when hit; it only disappears when it expires. | Guard, Brace for Impact |
| Plate X | Like Block, but permanent across turns until an enemy effect destroys it (Smash, Shred, Corrode, etc.). ⚙️ Max 20 hexes. ⚙️ Normal hits don't remove Plate. | Plate Up, Rampart |
| Plated hex | A hex that currently has Plate. Scaling cards count these. | Shield Bash, Bastion Crush |
| Retaliate X | When a covered hex (Block/Plate) is hit, deal X damage back to the enemy for each hit. The card states the duration, e.g. "this turn". | Thorn Guard, Parry |
| Fracture X | Destroy X of your own hexes as a cost. ⚙️ The player chooses them, and can't pick a Plated hex while any other hex is left. Block doesn't reduce it. The hexes can be healed back. | Reckless Swing, Cataclysm |
| Edge X | Every Attack played grows its pattern by X hexes (same role as Strength). The player places the extra hexes adjacent to the pattern. It applies to each hit of a multi-hit attack. "This turn" ends at end of turn; "this combat" lasts the whole fight. | Whetstone, Demon Edge |
| Exhaust (card) | After it's played, the card is removed for the rest of this combat and isn't reshuffled. It returns next combat. | Adrenaline, Berserk Rush |
| Exhaust X card (cost) | Choose X cards in hand to Exhaust as part of the effect. | Burn Offering, Scrap Armor |
| Retain | Not discarded at end of turn; stays in hand. | Hold the Line, Parry |
| Turn Block into Plate | Choose hexes that have Block and turn them into permanent Plate. | Fortify Grid |

## Status effects
| Keyword | Meaning |
|---|---|
| Poison X | At the start of the player's turn, lose 1 hex per stack. Goes through Block and Plate. Stacks drop by 1 each turn. ⚙️ Under the old "3 turns" rule, read Poison 3 as "lose 1 hex per turn for 3 turns". (Dark Elf: "Poison 3, lose 1 hex/turn for 3 turns, pierces Block".) |
| Stun | The enemy skips its next turn and takes no action (used by Ramiel). |
| Regen X | The enemy regains X HP each turn. |
| Edge (enemy) | Enemies can use Edge like the player: Hit patterns grow by X hexes. |
| Curse Wrap / Shiver / Lockdown / Screech | Conditional debuffs that change cost, cards drawn, or Block amount next turn. Each monster states its own effect. They don't stack. |

## Enemy keywords
| Keyword | Meaning | Example |
|---|---|---|
| Pierce (through Block) | This Hit skips Block, but Plate still protects. | Goblin Backstab, Frangenstein Static |
| Pierce Block/Plate | Skips every kind of protection. The only answer is to stop the monster first. | Ramiel Particle Beam |
| Smash / Shred / Corrode | Destroys Plate on the hit hexes or nearby ones (removes the stated amount). Counters a Fortress build. | Ogre, Cleaner Bot, Nano Swarm |
| Split | Below an HP threshold, splits into smaller monsters. | Slime |
| Fast | Hits several times per turn, each with its own intent. | Hound |
| Aerial / Hover / Wrapped | Reduces the damage of the first Attack each turn (by a flat amount or by half, as stated). Pushes the player to open with a small card. | Griffin, Scout Drone, Mummy |
| Ethereal | Caps the damage of a single Attack card, so big cards aren't worth it. | Lil Ghost |
| Rune Armor / Bone Armor / Armor Plating / Absolute Terror Field | The enemy has its own Block, which damage must wear down before HP goes down. It recharges on the stated cycle. | Magic Golem, Skeleton, Mech Walker, Ramiel |
| Rise | Revives once after dying, with the stated HP. | Zombie |
| Burning Head | If the player hits it with an Attack that meets the condition, the damage is reflected back. | Jack O Lantern |
| Moon Phase | Switches between two modes every turn, each with different rules and actions. | Warewolf |
| Stitched | Starts with some Plate. | Frangenstein |
| Phylactery | A separate object with its own HP. While it stands, the main body heals every turn. | Lich |
| Multi-head | Several hits per turn. A head can be cut off by dealing enough damage in one turn. | Hydra |
| Firewall | Immune to all debuffs. | Hacker AI |
| Consume | Heals HP every turn. | Nano Swarm |
| Overclock | Its number of actions grows each turn of a cycle, then resets. | Cyber Hound |
| Charge → Beam | A charge turn with no attack, followed by a heavy move. The player can interrupt or prepare a defence. | Ogre, Plasma Turret, Ramiel |
| Interrupt | Deal enough damage during a charge turn and the next move is cancelled. | Ramiel |
| P1 / P2 (Phase) | The boss switches action sets below 50% HP. | Dragon, Dracula, Ramiel |

## Decided
Where this differs from the sheet translation above, this section wins.

- **Block** replaces Shield (`ShieldTile`, `HealthTile.SHIELDED`, the "Shield" card).
  - It absorbs 1 hit, then it's gone. A second hit on the same hex in the same turn damages it.
  - It clears at the start of its owner's turn (the player's Block at the start of the player's turn, an enemy's at the start of the enemy's). Enemies may get Block skills later.
- **Plate** is a new tile effect. It doesn't expire, but each hit removes 1 stack (see For Mai #3), and the hex only takes damage once Plate is gone. Plate is never permanent (the sheet says only Smash / Shred / Corrode remove it; we don't follow that).
  - Not implemented yet, sheet draft only: the 20-hex cap and Smash / Shred / Corrode.
- Block and Plate can't go on a damaged hex.
- Block and Plate are `BaseTileEffect`s in `HealthTile.status_effects`, so `HealthTile.hp` becomes just 0 / 1. Each tile gets its own effect object (today one card shares one object across every tile it hits).
- Effect triggers (task #8, done together with #6):
  - `BaseEffect` gets two empty methods that subclasses override: `on_turn_start(combat, unit, cell)` and `on_hit(combat, unit, cell) -> bool` (true = the hit was absorbed). `CombatUnit` calls them on every tile's `status_effects` (tile-wise) and on its own `statuses` (global). More triggers get added when an effect needs one.
  - Player turn start: top of `CombatState.start_turn()`, before drawing and before enemies plan. Enemy turn start: in `end_turn()`, right before that enemy's `take_turn()`. So an enemy's Block lasts the whole player turn.
  - Every hit goes through `CombatUnit.damage_health_tile`, which asks the tile's effects (`on_hit`) before reducing hp. A pierce flag (Poison, Sacrifice) gets added there when needed.
- Grid colours: Block keeps today's blue, Plate is steel grey, stacks above 1 show as a small number. Draw order Block > Plate > other effects. If Block can sit on Plate (For Mai #4), it's drawn as 50% blue over the steel grey.
- **Slime Harden** and **Guarded Bash**'s self-shield use Plate. Ignore Rune Armor / Bone Armor / Armor Plating / Absolute Terror Field for now.
- The "Shield" card becomes **Guard** (`guard.gd`).
- **Strength** instead of Edge. Not implemented (task #7), and how the player places the extra hexes is undecided.
- **Sacrifice** instead of Fracture (the Card tab's "Trade 2" / "Sacifice 3" mean this too).
- Tooltips: **Exhaust, Retain, Sacrifice** get one, from a small list in `keywords.gd` (they aren't effects). **Draw** and **Cost X** don't.
- Numbers that don't fit the grids (Block 12 and Plate 15 on a 7-hex player, Slime 12 HP vs 17 hexes, bosses up to 170 HP) stay as they are for now.

## For Mai
The Block / Plate rename touches your files: `scripts/enemies/slime/slime_harden.gd`, `slime_guarded_bash.gd`, `base_enemy_action.gd` (`score_cell` checks `SHIELDED` and `ShieldTile`), `enemy_check.gd`, `scripts/cards/card_data/shield.gd` and `scripts/game/run_state.gd`. We'll only touch them after you've answered below.

Please tick one option, or write your own.

**1. Poison.** The code has `PoisonTileEffect` on single tiles (`ApplyEffectTile`). The sheet makes Poison X a stack on the whole unit: at the start of the turn, lose 1 hex, going through Block and Plate, then drop 1 stack. Its wording ("1 hex per stack") also contradicts its own note; Dark Elf ("lose 1 hex/turn for 3 turns") settles it as 1 hex per turn.
- [ ] Tile-wise: the poisoned tile itself is the one that gets damaged.
- [ ] Unit-wise: a stack on the unit (that's the Power/status task, #7), and we need a rule for which hex is lost.

**2. Damage with no pattern.** Retaliate, Living Wall and Ashes to Ashes "deal X to the enemy", often during the enemy's turn when the player can't click. My suggestion is one of these:
- [ ] Hit X random undamaged hexes (just random, no targeting logic).
- [ ] Remove these cards/keywords.
- [ ] Other:

**3. Can Block and Plate stack?** With stacks, Block 2 on a hex absorbs 2 hits. Without them, Block / Plate is on or off and absorbs 1 hit.
- [ ] Both stack. Block stacks still all expire at the start of the owner's next turn. (my suggestion)
- [ ] Only Plate stacks.
- [ ] Neither stacks.
- [ ] Other:

**4. Can Block and Plate be on the same hex?** Fortify Grid ("turn Block into Plate") works either way.
- [ ] No overlap: a hex has Block or Plate, not both. Also pick what happens when you apply one on a hex that has the other: [ ] nothing happens / [ ] the new one replaces it. (my suggestion)
- [ ] Overlap allowed: a hit uses up Block first, then Plate.
- [ ] Other:

**5. Which tile applies Block / Plate?** (my proposal, affects `score_cell`)
- [ ] Delete `ShieldTile` and use `ApplyEffectTile.new(cell, BlockTileEffect.new())` / `PlateTileEffect.new()`. Fewer classes; colour and tooltip come from the effect. `score_cell` checks `t is ApplyEffectTile and t.effect is BlockTileEffect`. (my suggestion)
- [ ] Keep thin `BlockTile` / `PlateTile` subclasses of `ApplyEffectTile`, so `score_cell` stays `t is BlockTile`.
- [ ] Other:

**6. Enemy targeting on protected hexes.** `score_cell` gives damage on a shielded hex 1 and on an open hex 2. A hit on Block / Plate now just uses up a stack.
- [ ] Keep it: a Blocked or Plated hex scores 1 no matter how many stacks, so open hexes are still preferred. (my suggestion)
- [ ] Other:
