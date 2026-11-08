class_name CombatState
extends RefCounted

signal enemy_spawned(enemy: CombatUnit, in_place_of: CombatUnit)  # the scene shows it in in_place_of's slot


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
var exhausted_this_turn := 0  # cards exhausted since the player's turn started


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
	exhausted_this_turn = 0
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
	for e in enemies.duplicate():  # enemies spawned this turn wait for the next one
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


## Adds enemy mid-fight, right after in_place_of, which leaves the field (Slime's Split).
## It plans its first move at the next player turn.
func spawn(enemy: CombatUnit, in_place_of: CombatUnit) -> void:
	enemies.insert(enemies.find(in_place_of) + 1, enemy)
	enemy_spawned.emit(enemy, in_place_of)


func can_play(card: BaseCard) -> bool:
	return card in hand and (card.x_cost or card.cost <= energy)


## Pays the cost, runs each grid action on units[i] at cells[i], then discards the card.
## Exhaust cards go to the exhaust pile instead, and to_draw_top cards on top of the draw pile.
## Power cards go to no pile: they stay in play for the rest of the fight. With Echo, an Attack runs twice.
## picks = the cards chosen to exhaust from hand (card.exhaust_from_hand), or to put on top of the draw pile
## from the discard pile (card.pick_from_discard). Moved before the card's effect.
## tile_picks = the player's tiles chosen for card.pick_tile, inflicted before the card's effect too.
func play_card(card: BaseCard, units: Array[CombatUnit], cells: Array[Vector2i], rotations: Array[int], picks: Array[BaseCard] = [], tile_picks: Array[Vector2i] = []) -> bool:
	if not can_play(card):
		return false
	energy -= energy if card.x_cost else card.cost
	hand.erase(card)
	for pick in picks:
		if card.pick_from_discard > 0:
			discard_pile.erase(pick)
			draw_pile.append(pick)  # draw() takes from the back
		else:
			exhaust(pick)
	for cell in tile_picks:
		card.pick_tile.inflict(self, player, cell)
	await flush()
	await card.execute(self, units, cells, rotations)
	if card.type == Enum.CardType.ATTACK and EchoPower.use(player):
		await card.execute(self, units, cells, rotations)
	if card.exhaust:
		exhaust(card)
	elif card.to_draw_top:
		draw_pile.append(card)  # draw() takes from the back
	elif card.type != Enum.CardType.POWER:
		discard_pile.append(card)
	return true


## Moves card from wherever it is to the exhaust pile, and counts it for this turn.
func exhaust(card: BaseCard) -> void:
	hand.erase(card)
	exhaust_pile.append(card)
	exhausted_this_turn += 1


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
