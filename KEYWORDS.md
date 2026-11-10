# Keywords

What each keyword does in the game now. Where a rule has a class behind it, the class is named. Effect and keyword wording is read from the code (`keywords.gd` and the effect classes), so if this file and the game disagree, the code wins.

## Core rules
| Keyword | Meaning |
|---|---|
| HP / Hex | HP is the hexes on a unit's grid. 1 hex = 1 HP. A hex that gets hit is damaged (lost). |
| Deal X | Attack the enemy for X damage. The player places the card's pattern on the enemy grid, and every hex it covers takes 1 damage. |
| Hit X | (Enemy side) The enemy hits X player hexes with the pattern shown in its intent. |
| Intent | The enemy shows its next action ahead of time (type, pattern, position) so the player can plan a defence. |
| Energy | Pays for cards. You get 3 at the start of each turn, and energy you don't spend doesn't carry over. |
| Cost X | An X-cost card spends all remaining energy, and its grid action is placed once per energy spent. |
| Draw X | Draw X more cards from the draw pile. If the draw pile is empty, shuffle the discard pile back in. |
| Discard | Move a card from hand to the discard pile. It comes back when the pile is reshuffled. |
| Damage with no pattern | Hit X random undamaged hexes, with no targeting logic (Retaliate, Living Wall, Ashes to Ashes). |

## Card types
| Type | How it plays |
|---|---|
| Attack | Hits the enemy with a pattern. Affected by Strength. |
| Defense | Places protection (Shield / Plate) on your own hexes. |
| Skill | General effects such as draw, energy, Retaliate, or status changes. Goes to the discard pile after it's played. |
| Power | Played once and lasts for the whole combat. Doesn't go back to the discard pile. |

## Protection
**Shield** (hard-coded: `hp == SHIELDED`, applied by `ShieldTile`)
- Absorbs 1 hit. A second hit on the same hex damages it.
- Never expires and doesn't stack.
- Can't go on a damaged hex.

**Pierce**
- A Pierce hit damages the tile even if it has Shield or Plate.
- Plate on that tile is removed as usual. There's one kind of Pierce, for both the player and enemies.

**Plate** (`PlateTileEffect`)
- A tile effect applied with `ApplyEffectTile`. Doesn't stack.
- At the start of its owner's turn it gives its tile Shield, unless the opponent attacked that tile during the opponent's last turn. A hit that Shield absorbed still counts as an attack.
- So there's no Shield on the turn it's cast. The first one comes at the owner's next turn start.
- Removed when its tile is damaged. Hitting a Plated hex that has Shield twice in one turn breaks the Shield and then removes the Plate.
- Can't go on a damaged hex.
- Smash (Ogre), Corrode (Nano Swarm) and Shred (Cleaner Bot) remove Plate. There's no cap on Plated hexes.

**Heal X**
- The player chooses X damaged hexes of their own to restore. If fewer are damaged, all of them are restored.

**Cleanse**
- Removes every debuff (Fracture, Poison) from a tile.

## Card keywords
| Keyword | Meaning |
|---|---|
| Exhaust | After it's played, the card is removed for the rest of this combat and isn't reshuffled. It returns next combat. |
| Retain | Not discarded at the end of your turn; stays in hand. |
| Repeat | The card's effect happens twice. |
| Sacrifice X | Destroy X of your own hexes as a cost. The player chooses them, and can't pick a Plated hex while any other hex is left. Shield doesn't absorb it. It can kill the caster. |
| Retaliate X | When a Shield absorbs a hit on your grid, deal X damage back to the attacker (see Damage with no pattern). Lasts until the start of your next turn. |
| Strength X | Each attack also damages X random tiles next to the cells it landed on (`StrengthPower`). The player doesn't place them. |

## Tile effects
Effects override `on_trigger(Enum.Trigger, combat, unit, cell)`. Each unit fires TURN_START / TURN_END on its own turn, and ON_HIT / ON_BLOCK when one of its tiles is hit. Effects tick at their owner's TURN_END.

| Effect | Meaning |
|---|---|
| Plate | See Protection. |
| Fracture | A debuff. When its tile is damaged, each adjacent tile takes 1 damage (a Shield there absorbs it). It doesn't chain. |
| Poison | A debuff (`PoisonTileEffect`). Explodes at the start of the victim's 2nd turn after it's applied, before Plate gives Shield. Its tile is damaged like Pierce, and each of the 6 adjacent tiles takes 1 hit. It stays if the tile is damaged first, can be applied to a damaged tile, doesn't chain, and does nothing if the tile is already poisoned. |
| Heroic | While every tile next to it is damaged (neighbours off the grid don't count), its owner gets 1 Strength. Each Heroic tile counts separately. `StrengthPower` checks it each time the Strength is used. Card: Heroic Stance. |
| AT Field | The tile can't be damaged while its owner has any other undamaged tile without AT Field. Ramiel only. |

## Powers
Player powers (cards that grant them):
| Power | Meaning |
|---|---|
| Strength | See Card keywords. |
| Retaliate | See Card keywords. |
| Echo | Your next Attack this turn is played twice. |
| Foresight | At the start of your turn, draw 1 more card per Foresight. |
| Unstoppable | At the start of your turn, gain 1 Strength per Unstoppable. |
| Ward | At the start of your turn, Shield 1 random tile per Ward. |
| Duelist | Every time you play 3 Attacks in a single turn, Shield 1 random tile per Duelist. |
| Living Wall | Whenever you gain Plate, deal damage to 1 random enemy tile per Living Wall. |
| Bloody Chalice | The first time you lose a health tile during your turn, gain 1 Energy per Bloody Chalice. |
| Oblation | Whenever a card is Exhausted, draw 1 card per Oblation. |
| Revival Chant | At the start of your turn, put 1 random card from your discard pile into your hand per Revival Chant. |
| Reserved Armory | When you play a Power card, put 1 random Attack from your draw pile into your hand per Reserved Armory. It costs 0 this turn. |
| Hallowed Knight | The first time you play an Attack costing 2 or more each turn, Cleanse 1 random tile per Hallowed Knight. |
| Chronic Sunburn | At the start of your turn, apply Fracture to 1 random enemy tile per Chronic Sunburn. |
| Piercing | Next turn, your Attacks deal Piercing damage. |

Debuffs enemies put on you:
| Power | Meaning |
|---|---|
| Curse Wrap | Your next Defense card places 1 fewer Shield or Plate per Curse Wrap. |
| Shiver | Your next card costs 1 more. (Lockdown is Shiver under another name.) |
| Screech | Draw 1 fewer card at the start of your next turn. |
| Hacked | Right after your next hand is drawn, a random card in it is Exhausted. |

## Enemy keywords
| Keyword | Meaning | Example |
|---|---|---|
| Regen X | At the start of its turn, heals X random damaged tiles. Some have a guard: no heal if it lost that many tiles since its last turn (Hydra: Regen 3, guard 8). `RegenPower`. | Hydra |
| Consume | Regen 5. | Nano Swarm |
| Aerial | The first X hits on it each of your turns miss, whatever Shield or Pierce says. | Griffin |
| Hover | Aerial under another name (the first 2 hits each turn miss). | Scout Drone |
| Wrapped | The first Attack card each of your turns deals half damage to it: every other hit misses. | Mummy |
| Ethereal | One Attack card can only hit it X times; the rest miss. | Lil Ghost |
| Burning Head | When one Attack card destroys 6 of its tiles, it burns 1 random tile of the attacker per stack. | Jack O Lantern |
| Full Moon / New Moon | Switches every turn. New Moon is human form. Full Moon is wolf form: each Attack card also hits 3 more random tiles of it. | Werewolf |
| Multi-head | Attacks once per head. Losing 10 tiles in one of your turns cuts off a head, once a turn. | Hydra |
| Rise | Comes back once after dying, with X tiles. | Zombie |
| Firewall | Immune to debuffs: Poison and Fracture can't be put on it. | Hacker AI |
| Rune Armor / Bone Armor / Armor Plating / Absolute Terror Field | Enemy Block is Shield on the enemy's own tiles. Armor Plating (Mech Walker) and Absolute Terror Field (Ramiel) start with 20 Shields and top them back up to 20 every 3rd turn, on tiles marked in the intent (`EnemyField`). Rune Armor is a power; Bone Armor is starting Shields. | Magic Golem, Skeleton, Mech Walker, Ramiel |
| Stitched | Starts with some Plate. | Frangenstein |
| Phylactery | A separate object with its own HP. While it stands, the main body heals every turn. | Lich |
| Split | Below an HP threshold, splits into smaller monsters. | Slime |
| Fast | Hits several times per turn, each with its own intent. | Hound |
| Overclock | Its number of actions grows each turn of a cycle, then resets. | Cyber Hound |
| Charge → Beam | A charge turn with no attack, followed by a heavy move. The player can interrupt or prepare a defence. | Ogre, Plasma Turret, Ramiel |
| Interrupt | Lose enough tiles during a charge and the next move is cancelled. Ramiel's becomes a "Stunned" turn that does nothing. | Ramiel |
| P1 / P2 (Phase) | The boss switches action sets below half its tiles. | Dragon, Dracula, Ramiel |
| Smash / Shred / Corrode | Removes Plate from every tile it covers (Smash, Corrode); Shred removes it from 4 Plated tiles marked in its intent. | Ogre, Cleaner Bot, Nano Swarm |

Move notes:
- Dragon's P2 Inferno is Fire Breath with Pierce.
- Scan (Scout Drone) aims its next Laser Ping's first hit and makes it 10 tiles instead of 6.
- Snipe (Android Sentinel) uses the usual Pierce, so Plate doesn't stop it.
- Execute (Terminator) is only planned while you have half your tiles or fewer; otherwise that turn is another Rifle Barrage. Rally gives every enemy 1 Strength.
- Hack (Hacker AI) gives you Hacked.
- Where a hit count and its shape disagree, the shape wins: Stomp hits 9 (3x3), Snipe 10 (1x10), Sweep 8 (a ring plus one tile on each side).

Enemy targeting: `score_cell` scores a shielded hex 1 and an open hex 2.

## Tooltips
- Shield, Exhaust, Retain, Repeat, Sacrifice, Heal, Cleanse and Pierce get theirs from the `NOT_EFFECTS` list in `keywords.gd`. Every effect (tile effect or power) gets its own from its class. Draw and Cost X get none.
- In a card description, `{keyword:Exhaust}` shows "Exhaust" and `{keyword:Exhaust|Exhausted}` shows "Exhausted" but is still the Exhaust keyword.
