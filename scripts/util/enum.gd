class_name Enum
extends RefCounted

# Every enum in the game

enum CardType { ATTACK, DEFENSE, SKILL, POWER }
enum CardRarity { COMMON, UNCOMMON, RARE, LEGENDARY }
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
	CARD_SHOP, # cards and artifacts
	BLACKSMITH, # sells augments
	TREASURE,
	EVENT,
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
	POWER,  # a unit gained a power
	HEAL,   # a damaged tile got its health back
}
