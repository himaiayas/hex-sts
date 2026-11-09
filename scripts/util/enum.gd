class_name Enum
extends RefCounted

# Every enum in the game

enum CardType { ATTACK, DEFENSE, SKILL, POWER }
enum CardRarity { COMMON, UNCOMMON, RARE, LEGENDARY, STARTER } # STARTER: the opening deck only, never offered; last so saved values keep their meaning
enum ArtifactRarity { COMMON, UNCOMMON, RARE, LEGENDARY }


enum TargetType { PLAYER, ENEMY }

enum HealthTileEnum {
	DAMAGED = 0,
	UNDAMAGED = 1,
	SHIELDED = 2,
}
enum BaseEnemyActionEnum {
	ATTACK,
	DEFEND,
	BUFF,
	DEBUFF,
	WIND_UP, # no effect now: aims a move that lands on a later turn
}

enum Side {
	PLAYER, # player's health grid
	SELF,   # enemy's health grid
}

enum RoomType {
	START,
	NORMAL_COMBAT,
	ELITE_COMBAT,
	BOSS_COMBAT,
	CAMPFIRE,
	MERCHANT, # sells cards and artifacts
	BLACKSMITH, # sells augments
	TREASURE,
	EVENT,
	INTERSECTION, # empty, doors on every side: for connecting the map (last, so saved runs keep their numbers)
}


enum Trigger {
	COMBAT_START, # once, at the start of the first player turn (after energy is set)
	TURN_START, # start of the owner's turn
	TURN_END,   # end of the owner's turn, before turn counters tick down
	ON_HIT,     # damage took a tile's health
	ON_BLOCK,   # a shield absorbed damage
}


enum Change { # what CombatState.record() saw, so the views know what to animate
	DAMAGE, # a tile lost its health
	BLOCK,  # a shield absorbed a hit
	SHIELD, # a tile got a shield
	EFFECT, # a tile effect went on a tile
	EFFECT_LOST, # a tile effect was taken off a tile (Smash)
	POWER,  # a unit gained a power
	HEAL,   # a damaged tile got its health back
}
