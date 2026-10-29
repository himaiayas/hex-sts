class_name CombatRewards
extends RefCounted

## What the player gets for winning a fight: pick 1 of 3 cards, coins, and EXP.
## Amounts depend on the room type; tune them here.

const CARD_CHOICES := 3

## Coins, as [min, max] (inclusive).
const GOLD := {
	Enum.RoomType.NORMAL_COMBAT: Vector2i(10, 20),
	Enum.RoomType.ELITE_COMBAT: Vector2i(25, 35),
	Enum.RoomType.BOSS_COMBAT: Vector2i(60, 80),
}

const EXP := {
	Enum.RoomType.NORMAL_COMBAT: 10,
	Enum.RoomType.ELITE_COMBAT: 25,
	Enum.RoomType.BOSS_COMBAT: 60,
}

var gold := 0
var exp_points := 0
var cards: Array[BaseCard] = []

var gold_taken := false
var exp_taken := false
var card_taken := false  # picked one, or skipped


static func roll(room_type: Enum.RoomType) -> CombatRewards:
	var rewards := CombatRewards.new()
	var gold_range: Vector2i = GOLD.get(room_type, GOLD[Enum.RoomType.NORMAL_COMBAT])
	rewards.gold = randi_range(gold_range.x, gold_range.y)
	rewards.exp_points = EXP.get(room_type, EXP[Enum.RoomType.NORMAL_COMBAT])
	rewards.cards = CardPool.random_cards(CARD_CHOICES)
	return rewards


func take_gold(run: Node) -> void:
	if not gold_taken:
		run.gold += gold
		gold_taken = true


func take_exp(run: Node) -> void:
	if not exp_taken:
		run.add_xp(exp_points)
		exp_taken = true


## card = null skips the card reward.
func take_card(run: Node, card: BaseCard) -> void:
	if card_taken:
		return
	if card:
		run.deck.append(card)
	card_taken = true
