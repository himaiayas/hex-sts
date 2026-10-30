class_name CombatState
extends RefCounted


# Temporary state for combat encounter
const HAND_LIMIT := 10
const DRAW_PER_TURN := 5

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
	player.artifacts = run.artifacts
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


func start_turn() -> void:
	turn += 1
	energy = max_energy
	if turn == 1:
		player.fire(Enum.Trigger.COMBAT_START, self)
	player.on_turn_start(self)
	draw(DRAW_PER_TURN)
	for e in enemies:
		var enemy := e as BaseEnemy
		if enemy and not enemy.is_dead():
			enemy.plan(self)


func end_turn() -> void:
	discard_hand()
	player.on_turn_end(self)
	for e in enemies:
		if is_lost():
			return  # the fight is lost; don't start another turn
		var enemy := e as BaseEnemy
		if enemy == null or enemy.is_dead():
			continue
		enemy.on_turn_start(self)
		if not enemy.is_dead():  # its own effects may have finished it
			enemy.take_turn(self)
		enemy.on_turn_end(self)
	if is_lost() or is_won():
		return
	start_turn()


func can_play(card: BaseCard) -> bool:
	return card in hand and card.cost <= energy


## Pays the cost, runs each grid action on units[i] at cells[i], then discards the card.
func play_card(card: BaseCard, units: Array[CombatUnit], cells: Array[Vector2i], rotations: Array[int]) -> bool:
	if not can_play(card):
		return false
	energy -= card.cost
	hand.erase(card)
	card.execute(self, units, cells, rotations)
	discard_pile.append(card)
	return true


func is_won() -> bool:
	return not player.is_dead() and enemies.all(func(e: CombatUnit) -> bool: return e.is_dead())


func is_lost() -> bool:
	return player.is_dead()


func finish(run: Node) -> void:
	for tile in player.health.values():
		tile.status_effects.clear()  # tile effects only last for the fight
	run.health = player.health
