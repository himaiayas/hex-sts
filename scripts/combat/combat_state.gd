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
## Set by the combat scene: lets the player move one enemy part aimed at them, awaited by
## relocate_intents(). Gets {part, min_hits}; returns the part's new cell (its old one to keep it).
var relocator: Callable
var _changes: Array[Dictionary] = []  # recorded since the last flush

var max_energy := 3
var energy := 0
var turn := 0
var exhausted_this_turn := 0  # cards exhausted since the player's turn started
var exhausted_this_combat := 0
var played_this_turn: Array[BaseCard] = []  # cards the player started playing this turn, in order
var player_tiles_destroyed := 0  # player tiles damaged this combat, counting a healed tile again (Bloodlust Strike)
var extra_turns := 0  # player turns to take right after this one, skipping the enemies (Chronokinesis)
var end_turn_requested := false  # a card asked to end the turn once it has resolved; the scene does it
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
	if kind == Enum.Change.DAMAGE and unit == player:
		player_tiles_destroyed += 1


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


## Tiles of part that would change something on the player's grid if it went at cell.
func part_hits(part: EnemyActionPart, cell: Vector2i) -> int:
	var hits := 0
	for t in part.tiles:
		if t.can_inflict(player, cell + t.coords):
			hits += 1
	return hits


## Taunt: the player moves each enemy part aimed at them this turn, one at a time. Each must still
## hit at least one tile fewer than where it was. Without a relocator (headless) nothing moves.
func relocate_intents() -> void:
	if not relocator.is_valid():
		return
	for enemy in enemies:
		if not enemy is BaseEnemy or enemy.is_dead():
			continue
		for action: BaseEnemyAction in enemy.intent_actions:
			for part in action.parts:
				if part.side != Enum.Side.PLAYER:
					continue
				var min_hits := maxi(0, part_hits(part, part.cell) - 1)
				part.cell = await relocator.call({part = part, min_hits = min_hits})


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


## Puts a new card in the hand, or on the discard pile if the hand is full.
func add_to_hand(card: BaseCard) -> void:
	if hand.size() >= HAND_LIMIT:
		discard_pile.append(card)
	else:
		hand.append(card)


## Retain cards stay in hand.
func discard_hand() -> void:
	discard_pile.append_array(hand.filter(func(c: BaseCard) -> bool: return not c.retain))
	hand.assign(hand.filter(func(c: BaseCard) -> bool: return c.retain))


## replan: false on an extra turn, so the enemies keep the intents they already showed.
func start_turn(replan := true) -> void:
	turn += 1
	exhausted_this_turn = 0
	played_this_turn.clear()
	energy = max_energy
	if turn == 1:
		await player.fire(Enum.Trigger.COMBAT_START, self)
	await player.on_turn_start(self)
	draw(DRAW_PER_TURN - player.power_amount(ScreechPower))
	if player.power_amount(HackedPower) > 0 and not hand.is_empty():
		exhaust(hand.pick_random())
	if not replan:
		return
	for e in enemies:
		var enemy := e as BaseEnemy
		if enemy and not enemy.is_dead():
			enemy.plan(self)


func end_turn() -> void:
	discard_hand()
	await player.on_turn_end(self)
	if extra_turns > 0 and not is_lost() and not is_won():
		extra_turns -= 1
		await start_turn(false)
		return
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



## In hand, affordable, its own rule (BaseCard.can_play) allows it, and every must_land pattern
## fits somewhere it can go.
func can_play(card: BaseCard) -> bool:
	if card not in hand or not can_afford(card) or not card.can_play(self):
		return false
	for action in card.placements():
		var units: Array[CombatUnit] = [player]
		if action.target == Enum.TargetType.ENEMY:
			units = enemies.filter(func(e: CombatUnit) -> bool: return not e.is_dead())
		if not units.any(func(u: CombatUnit) -> bool: return action.can_place_anywhere(u)):
			return false
	return true


func can_afford(card: BaseCard) -> bool:
	return card.x_cost or cost_of(card) <= energy


## What card costs now: 0 on its free_on_turn, and Shiver adds 1 to the next card.
func cost_of(card: BaseCard) -> int:
	var base := 0 if card.free_on_turn == turn else card.cost
	return base + player.power_amount(ShiverPower)


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
	played_this_turn.append(card)
	playing = card
	await card.execute(self, units, cells, rotations)
	if card.type == Enum.CardType.ATTACK and EchoPower.use(player):
		await card.execute(self, units, cells, rotations)
	playing = null
	for power in player.statuses.duplicate():
		if power is BasePower:
			power.on_card_played(self, player, card)
	await flush()  # what those powers changed (Hallowed Knight's cleanse)
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


## Moves card from wherever it is to the exhaust pile, counts it, and tells every card (Burnout).
func exhaust(card: BaseCard) -> void:
	hand.erase(card)
	exhaust_pile.append(card)
	exhausted_this_turn += 1
	exhausted_this_combat += 1
	for other in draw_pile + hand + discard_pile + exhaust_pile:
		other.on_card_exhausted(self)
	if playing:
		playing.on_card_exhausted(self)
	for power in player.statuses.duplicate():
		if power is BasePower:
			power.on_card_exhausted(self, player, card)


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
