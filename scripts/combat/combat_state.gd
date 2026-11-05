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
var animator: Callable  # set by the combat scene: plays one batch of changes, awaited by flush()
var _changes: Array[Dictionary] = []  # recorded since the last flush

var max_energy := 3
var energy := 0
var turn := 0


func _init(run: Node) -> void:
	player = CombatUnit.new("Player", run.health, true)
	player.artifacts = run.artifacts
	for card in run.deck:
		draw_pile.append(card.duplicate())
	draw_pile.shuffle()


## Called by CombatUnit whenever a tile or a power changes. effect = the tile effect or power, if any.
func record(unit: CombatUnit, cell: Vector2i, kind: Enum.Change, effect: BaseEffect = null) -> void:
	_changes.append({unit = unit, cell = cell, kind = kind, effect = effect})


## Plays the changes recorded since the last flush, and returns once they're done.
## Without an animator (headless checks) nothing waits.
func flush() -> void:
	if _changes.is_empty():
		return
	var batch := _changes
	_changes = []
	if animator.is_valid():
		await animator.call(batch)


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


## Retain cards stay in hand.
func discard_hand() -> void:
	discard_pile.append_array(hand.filter(func(c: BaseCard) -> bool: return not c.retain))
	hand.assign(hand.filter(func(c: BaseCard) -> bool: return c.retain))


func start_turn() -> void:
	turn += 1
	energy = max_energy
	if turn == 1:
		await player.fire(Enum.Trigger.COMBAT_START, self)
	await player.on_turn_start(self)
	draw(DRAW_PER_TURN)
	for e in enemies:
		var enemy := e as BaseEnemy
		if enemy and not enemy.is_dead():
			enemy.plan(self)


func end_turn() -> void:
	discard_hand()
	await player.on_turn_end(self)
	for e in enemies:
		if is_lost():
			return  # the fight is lost; don't start another turn
		var enemy := e as BaseEnemy
		if enemy == null or enemy.is_dead():
			continue
		await enemy.on_turn_start(self)
		if not enemy.is_dead():  # its own effects may have finished it
			await enemy.take_turn(self)
		await enemy.on_turn_end(self)
	if is_lost() or is_won():
		return
	await start_turn()


func can_play(card: BaseCard) -> bool:
	return card in hand and card.cost <= energy


## Pays the cost, runs each grid action on units[i] at cells[i], then discards the card.
## Exhaust cards go to the exhaust pile instead. Power cards go to no pile: they stay in play for the rest of the fight.
## picks = the cards in hand chosen to exhaust (card.exhaust_from_hand), exhausted before the card's effect.
func play_card(card: BaseCard, units: Array[CombatUnit], cells: Array[Vector2i], rotations: Array[int], picks: Array[BaseCard] = []) -> bool:
	if not can_play(card):
		return false
	energy -= card.cost
	hand.erase(card)
	for pick in picks:
		hand.erase(pick)
		exhaust_pile.append(pick)
	await card.execute(self, units, cells, rotations)
	if card.exhaust:
		exhaust_pile.append(card)
	elif card.type != Enum.CardType.POWER:
		discard_pile.append(card)
	return true


## The unit whose turn it is: the player, or the enemy taking its turn. Null between turns.
func acting_unit() -> CombatUnit:
	if player.in_turn:
		return player
	for enemy in enemies:
		if enemy.in_turn:
			return enemy
	return null


func is_won() -> bool:
	return not player.is_dead() and enemies.all(func(e: CombatUnit) -> bool: return e.is_dead())


func is_lost() -> bool:
	return player.is_dead()


func finish(run: Node) -> void:
	for tile in player.health.values():
		tile.status_effects.clear()  # tile effects only last for the fight
	run.health = player.health
