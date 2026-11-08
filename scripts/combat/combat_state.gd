class_name CombatState
extends RefCounted

signal enemy_spawned(enemy: CombatUnit, in_place_of: CombatUnit)  # the scene shows it in in_place_of's slot, or beside when null


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
## Set by the combat scene: lets the player pick cards, awaited by choose_cards().
## Gets {cards, in_hand, count, prompt}; returns the picked cards.
var chooser: Callable
var _changes: Array[Dictionary] = []  # recorded since the last flush

var max_energy := 3
var energy := 0
var turn := 0
var exhausted_this_turn := 0  # cards exhausted since the player's turn started
var playing: BaseCard  # the card whose effect is running now, for powers that react per card


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


## The player picks count of these cards (fewer if there aren't that many). in_hand: they're
## picked in the hand, otherwise in the pile viewer. Without a chooser (headless) the first ones.
func choose_cards(cards: Array[BaseCard], count: int, prompt: String, in_hand: bool) -> Array[BaseCard]:
	count = mini(count, cards.size())
	var picked: Array[BaseCard] = []
	if count == 0:
		return picked
	if not chooser.is_valid():
		picked.assign(cards.slice(0, count))
		return picked
	picked.assign(await chooser.call({cards = cards, in_hand = in_hand, count = count, prompt = prompt}))
	return picked


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
	draw(DRAW_PER_TURN - player.power_amount(ScreechPower))
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


## Adds enemy mid-fight, right after next_to. With replace, next_to leaves the field (Slime's Split);
## without, it stays (Lich's Summon). The new enemy plans its first move at the next player turn.
func spawn(enemy: CombatUnit, next_to: CombatUnit, replace := true) -> void:
	enemies.insert(enemies.find(next_to) + 1, enemy)
	enemy_spawned.emit(enemy, next_to if replace else null)



## In hand, affordable, and every must_land pattern fits somewhere it can go.
func can_play(card: BaseCard) -> bool:
	if card not in hand or not (card.x_cost or cost_of(card) <= energy):
		return false
	for action in card.placements():
		var units: Array[CombatUnit] = [player]
		if action.target == Enum.TargetType.ENEMY:
			units = enemies.filter(func(e: CombatUnit) -> bool: return not e.is_dead())
		if not units.any(func(u: CombatUnit) -> bool: return action.can_place_anywhere(u)):
			return false
	return true


## What card costs now: Shiver adds 1 to the next card.
func cost_of(card: BaseCard) -> int:
	return card.cost + player.power_amount(ShiverPower)


## Energy an X-cost card gets to use: all of it, minus Shiver's extra 1.
func x_energy() -> int:
	return maxi(0, energy - player.power_amount(ShiverPower))


## Pays the cost, runs each grid action on units[i] at cells[i], then discards the card.
## Exhaust cards go to the exhaust pile instead, and to_draw_top cards on top of the draw pile.
## Power cards go to no pile: they stay in play for the rest of the fight. With Echo, an Attack runs twice.
## Anything the card has the player pick (cards, tiles) is asked for while it resolves, through chooser.
func play_card(card: BaseCard, units: Array[CombatUnit], cells: Array[Vector2i], rotations: Array[int]) -> bool:
	if not can_play(card):
		return false
	energy = 0 if card.x_cost else energy - cost_of(card)
	hand.erase(card)
	playing = card
	await card.execute(self, units, cells, rotations)
	if card.type == Enum.CardType.ATTACK and EchoPower.use(player):
		await card.execute(self, units, cells, rotations)
	playing = null
	for power in player.statuses.duplicate():
		if power is BasePower:
			power.on_card_played(self, player, card)
	if card.exhaust:
		exhaust(card)
	elif card.to_draw_top:
		draw_pile.append(card)  # draw() takes from the back
	elif card.type != Enum.CardType.POWER:
		discard_pile.append(card)
	return true


## Moves card from the hand to the discard pile.
func discard(card: BaseCard) -> void:
	hand.erase(card)
	discard_pile.append(card)


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
