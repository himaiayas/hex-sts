class_name Enum
extends RefCounted

# Every enum in the game

enum CardType { ATTACK, DEFENSE, SKILL, POWER }
enum CardRarity { COMMON, UNCOMMON, RARE, LEGENDARY }


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
	COMBAT,
}
