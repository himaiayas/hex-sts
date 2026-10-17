class_name CombatState
extends RefCounted


# Temporary state for combat encounter
const HAND_LIMIT := 10

var player: CombatUnit
var enemies: Array[CombatUnit] = []

var draw_pile: Array[BaseCard] = []
var hand: Array[BaseCard] = []
var discard_pile: Array[BaseCard] = []
var exhaust_pile: Array[BaseCard] = []

var max_energy := 3
var energy := 0
var turn := 0


func _init(run: Node) -> void:
	player = CombatUnit.new("Player", run.health, true)
	for card in run.deck:
		draw_pile.append(card.duplicate())
	draw_pile.shuffle()


func draw(amount: int) -> void:
	for i in amount:
		if hand.size() >= HAND_LIMIT:
			return
		if draw_pile.is_empty():
			if discard_pile.is_empty():
				return
			draw_pile = discard_pile
			discard_pile = []
			draw_pile.shuffle()
		hand.append(draw_pile.pop_back())


func discard_hand() -> void:
	discard_pile.append_array(hand)
	hand.clear()


# func is_over() -> bool:
# 	return player.is_dead() or enemies.all(func(e: CombatUnit) -> bool: return e.is_dead())


func finish(run: Node) -> void:
	run.hp = player.hp
