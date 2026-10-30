# Keywords

English translation of the **Keywords** tab of the design sheet
(https://docs.google.com/spreadsheets/d/1ka0HmraZKJdy5WNRn9CmD43_94UFQQe9Yh29IsCXNtU, tab "Keywords").
⚙️ marks a rule clarification that was already in the sheet. The examples come from the sheet's Card and Monster tabs.
The last section, "Decided", is not from the sheet. It says how the keywords map to our code, as agreed in issue #8.

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
Agreed with Mai in issue #8. Where this differs from the sheet translation above, this section wins.

**Shield** (the sheet's Block and Plate are replaced by Shield + Plate below)
- Block and Shield are the same thing. We call it Shield.
- Shield stays hard-coded: `hp == SHIELDED`, applied by `ShieldTile`. No rename.
- It stays until it's hit, and it absorbs 1 hit. A second hit on the same hex damages it. It never expires and doesn't stack.
- Shield can't go on a damaged hex.

**Plate**
- A tile effect (`PlateTileEffect`), applied with `ApplyEffectTile`. It doesn't stack.
- At the start of each of its owner's turns, it gives its tile Shield, unless the opponent attacked that tile during the opponent's last turn. A hit that Shield absorbed still counts as an attack.
- So there's no Shield on the turn it's cast. The first one comes at the owner's next turn start, if the tile wasn't attacked in between.
- It's removed when its tile's hp reaches 0 (ON_HIT). Hitting a Plated hex that has Shield twice in one turn breaks the Shield and then removes the Plate.
- Plate can't go on a damaged hex.
- Not implemented, sheet draft only: the 20-hex cap and Smash / Shred / Corrode.
- Slime Harden and Guarded Bash's self-shield use Plate.

**Poison**
- A tile effect: at the start of its owner's turn, its tile takes 1 damage (a Shield on that tile absorbs it).
- Both the player and enemies can apply it.
- At TURN_START, Poison fires before Plate gives Shield, so Plate on its own doesn't make a tile immune. Poison damage on the owner's own turn doesn't count as an attack for Plate.

**Triggers** (task #8, already on main)
- Effects override `on_trigger(Enum.Trigger, combat, unit, cell)`. Each unit fires TURN_START / TURN_END on its own turn, and ON_HIT / ON_BLOCK when one of its tiles is hit.
- Effects tick at their owner's TURN_END.

**Damage with no pattern** (Retaliate, Living Wall, Ashes to Ashes)
- Hit X random undamaged hexes, with no targeting logic.

**Enemy targeting**
- `score_cell` stays as it is: a shielded hex scores 1, an open hex scores 2.

**Names and tooltips**
- Strength instead of Edge. Not implemented (task #7), and how the player places the extra hexes is undecided.
- Sacrifice instead of Fracture (the Card tab's "Trade 2" / "Sacifice 3" mean this too).
- Tooltips: Shield, Exhaust, Retain and Sacrifice get one from a small list in `keywords.gd` (they aren't effects). Plate and Poison get theirs from their effect class. Draw and Cost X get none.
- The "Shield" card keeps its name.
- Rune Armor / Bone Armor / Armor Plating / Absolute Terror Field are ignored for now.
- Numbers that don't fit the grids (Block 12 and Plate 15 on a 7-hex player, Slime 12 HP vs 17 hexes, bosses up to 170 HP) stay as they are for now.
