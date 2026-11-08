extends SceneTree

## Headless check for BaseEnemy / Slime / Goblin / Vermin / Hound / Ogre / Magic Golem / Dark Elf / Griffin / Hydra / Skeleton / Bat / Zombie / Frangenstein / Jack O Lantern / Lil Ghost / Mummy / Warewolf / Dragon / Dracula / Ramiel. Exit code = number of failures.
## godot --headless --path . -s res://scripts/enemies/enemy_check.gd

var _failures := 0


func _initialize() -> void:
	var run: Node = load("res://scripts/game/run_state.gd").new()
	run.start_new_run()
	var combat := CombatState.new(run)
	var slime := Slime.new()
	combat.enemies.append(slime)

	# Splat -> Goo, looped. Splat damages exactly the tiles its intent shows; Goo shields 4 of its own.
	var names: Array[String] = []
	for i in 6:
		_heal(combat.player)
		_heal(slime)
		slime.plan(combat)
		var action := slime.intent_actions[0]
		names.append(action.action_name)
		var expect_damaged := {}
		for part in action.parts:
			for cell in _covered(combat.player, part):
				expect_damaged[cell] = true
		await slime.take_turn(combat)
		var damaged := _cells_with(combat.player, Enum.HealthTileEnum.DAMAGED)
		_check(damaged == expect_damaged.size() and _all_in(combat.player, expect_damaged, Enum.HealthTileEnum.DAMAGED),
			"turn %d (%s): player damage doesn't match intent" % [i, action.action_name])
		if action is EnemyShieldSelf:
			_check(_cells_with(slime, Enum.HealthTileEnum.SHIELDED) == 4, "goo should shield 4")
		_check(slime.intent_actions.is_empty(), "turn %d: intent not cleared after take_turn" % i)
	_check(names == ["Splat", "Goo", "Splat", "Goo", "Splat", "Goo"], "slime order: %s" % [names])

	await _check_slime_split(combat)
	await _check_goblin(combat)
	await _check_vermin(combat)
	await _check_hound(combat)
	await _check_ogre(combat)
	await _check_golem(combat)
	await _check_dark_elf(combat)
	await _check_griffin(combat)
	await _check_hydra(combat)
	await _check_skeleton(combat)
	await _check_bat(combat)
	await _check_zombie(combat)
	await _check_frangenstein(combat)
	await _check_jack(combat)
	await _check_lil_ghost(combat)
	await _check_mummy(combat)
	await _check_warewolf(combat)
	await _check_dragon(combat)
	await _check_dracula(combat)
	await _check_ramiel(combat)

	run.free()
	print("enemy_check: %s" % ("OK" if _failures == 0 else "%d failure(s)" % _failures))
	quit(_failures)


func _check_slime_split(combat: CombatState) -> void:
	var player := combat.player

	# 7 tiles left: still Splat. The 6th left turns the intent into Split at once.
	var slime := Slime.new()
	combat.enemies = [slime]
	var cells: Array = slime.health.keys()
	slime.plan(combat)
	for i in 5:
		slime.damage_health_tile(combat, cells[i])
	_check(_rows(slime) == "Splat", "7 tiles left should still Splat: %s" % _rows(slime))
	slime.damage_health_tile(combat, cells[5])
	_check(_rows(slime) == "Split", "6 tiles left should Split: %s" % _rows(slime))

	# On its turn it splits instead of attacking: gone, with 2 Mini Slimes of 3 tiles in its place.
	# They don't act that turn, then plan Tiny Splat for the next one.
	_heal(player)
	await combat.end_turn()
	_check(_cells_with(player, Enum.HealthTileEnum.DAMAGED) == 0, "split turn shouldn't attack")
	_check(slime.is_dead() and combat.enemies.size() == 3 and combat.enemies.slice(1).all(func(e: CombatUnit) -> bool: return e is MiniSlime and e.health.size() == 3),
		"slime should become 2 mini slimes: %s" % [combat.enemies])
	_check(not combat.is_won(), "won with the mini slimes still alive")
	var minis := combat.enemies.slice(1)
	_check(minis.all(func(m: MiniSlime) -> bool: return _rows(m) == "Tiny Splat"), "mini slimes should plan Tiny Splat")
	for mini in minis:
		for cell in mini.health:
			mini.damage_health_tile(combat, cell)
	_check(combat.is_won(), "killing both mini slimes should win")

	# Destroyed outright, it doesn't split.
	slime = Slime.new()
	combat.enemies = [slime]
	slime.plan(combat)
	for cell in slime.health:
		slime.damage_health_tile(combat, cell)
	await combat.end_turn()
	_check(combat.enemies.size() == 1, "a destroyed slime split")



func _check_goblin(combat: CombatState) -> void:
	var goblin := Goblin.new()
	combat.enemies = [goblin]
	var player := combat.player

	# Stab -> Backstab, looped. Stab hits 5 open tiles; Backstab pierces Shield.
	var names: Array[String] = []
	for i in 4:
		_heal(player)
		for tile in player.health.values():
			tile.hp = Enum.HealthTileEnum.SHIELDED if i % 2 else Enum.HealthTileEnum.UNDAMAGED
		goblin.plan(combat)
		var action := goblin.intent_actions[0]
		names.append(action.action_name)
		var hit := _covered(player, action.parts[0])
		await goblin.take_turn(combat)
		_check(hit.size() == (5 if i % 2 == 0 else 3) and _cells_with(player, Enum.HealthTileEnum.DAMAGED) == hit.size(),
			"goblin %s should damage %d tiles, damaged %d" % [action.action_name, 5 if i % 2 == 0 else 3, _cells_with(player, Enum.HealthTileEnum.DAMAGED)])
	_check(names == ["Stab", "Backstab", "Stab", "Backstab"], "goblin order: %s" % [names])



func _check_vermin(combat: CombatState) -> void:
	var vermin := Vermin.new()
	combat.enemies = [vermin]
	var player := combat.player

	# Gnaw -> Gnaw -> Skitter, looped. Each Gnaw lands two bites on tiles that aren't damaged yet.
	var names: Array[String] = []
	for i in 6:
		_heal(player)
		_heal(vermin)
		for cell in player.health.keys().slice(0, 12):
			player.health[cell].hp = Enum.HealthTileEnum.DAMAGED
		vermin.plan(combat)
		var action := vermin.intent_actions[0]
		names.append(action.action_name)
		if action is EnemyHit:
			for part in action.parts:
				_check(_covered(player, part).any(func(c: Vector2i) -> bool: return player.health[c].hp > Enum.HealthTileEnum.DAMAGED),
					"gnaw put a bite where nothing is left")
		await vermin.take_turn(combat)
		if action is EnemyShieldSelf:
			_check(_cells_with(vermin, Enum.HealthTileEnum.SHIELDED) == 5, "skitter should shield 5")
	_check(names == ["Gnaw", "Gnaw", "Skitter", "Gnaw", "Gnaw", "Skitter"], "vermin order: %s" % [names])



func _check_hound(combat: CombatState) -> void:
	var hound := Hound.new()
	combat.enemies = [hound]
	var player := combat.player

	# Bite (2 hits), Bite, Lunge, looped. With 3 tiles left, the two hits can't land on the same one.
	var names: Array[String] = []
	for i in 6:
		_heal(player)
		for cell in player.health.keys().slice(0, 16):
			player.health[cell].hp = Enum.HealthTileEnum.DAMAGED
		hound.plan(combat)
		var action := hound.intent_actions[0]
		names.append(action.action_name)
		var expect := {}
		for part in action.parts:
			for cell in _covered(player, part):
				if player.health[cell].hp > Enum.HealthTileEnum.DAMAGED:
					expect[cell] = true
		await hound.take_turn(combat)
		if action.parts.size() == 2:
			_check(expect.size() >= 2, "the two bites landed on the same open tile")
		_check(_cells_with(player, Enum.HealthTileEnum.DAMAGED) == 16 + expect.size(), "hound turn %d didn't damage what its intent showed" % i)
	_check(names == ["Bite", "Bite", "Lunge", "Bite", "Bite", "Lunge"], "hound order: %s" % [names])



func _check_ogre(combat: CombatState) -> void:
	var ogre := Ogre.new()
	combat.enemies = [ogre]
	var player := combat.player

	# Wind-up aims without attacking; Smash lands there and strips Plate even where Shield blocks.
	var names: Array[String] = []
	for i in 4:
		_heal(player)
		for tile in player.health.values():
			tile.hp = Enum.HealthTileEnum.SHIELDED
			tile.status_effects.append(PlateTileEffect.new())
		ogre.plan(combat)
		var action := ogre.intent_actions[0]
		names.append(action.action_name)
		var aimed := _covered(player, action.parts[0])
		await ogre.take_turn(combat)
		var stripped := player.health.keys().filter(func(c: Vector2i) -> bool: return not player.health[c].has_effect(PlateTileEffect))
		stripped.sort()
		if action is OgreWindUp:
			_check(stripped.is_empty() and _cells_with(player, Enum.HealthTileEnum.SHIELDED) == player.health.size(), "wind-up touched the player")
		else:
			_check(aimed.size() == 12 and stripped == aimed, "smash should strip Plate from the 12 aimed tiles, stripped %d" % stripped.size())
			_check(_cells_with(player, Enum.HealthTileEnum.UNDAMAGED) == 12, "smash should break the 12 shields")
	_check(names == ["Wind-up", "Smash", "Wind-up", "Smash"], "ogre order: %s" % [names])



func _check_golem(combat: CombatState) -> void:
	var golem := MagicGolem.new()
	combat.enemies = [golem]
	var player := combat.player
	_check(_cells_with(golem, Enum.HealthTileEnum.SHIELDED) == MagicGolem.RUNE_START, "golem should start with %d shields" % MagicGolem.RUNE_START)
	_check(golem.power_amount(RuneArmorPower) == MagicGolem.RUNE_EVERY_TURN, "golem should start with Rune Armor %d" % MagicGolem.RUNE_EVERY_TURN)

	# Arcane Bolt -> Charge -> Overload, looped, with Rune Armor's 5 Shields before each move.
	var names: Array[String] = []
	for i in 6:
		_heal(player)
		_heal(golem)
		golem.plan(combat)
		var action := golem.intent_actions[0]
		names.append(action.action_name)
		await golem.on_turn_start(combat)
		_check(_cells_with(golem, Enum.HealthTileEnum.SHIELDED) == MagicGolem.RUNE_EVERY_TURN, "rune armor should shield %d before the move" % MagicGolem.RUNE_EVERY_TURN)
		await golem.take_turn(combat)
		await golem.on_turn_end(combat)
		if action is EnemyHit:
			_check(_cells_with(player, Enum.HealthTileEnum.DAMAGED) == _covered(player, action.parts[0]).size(), "%s didn't damage what its intent showed" % action.action_name)
		else:
			_check(_cells_with(golem, Enum.HealthTileEnum.SHIELDED) == MagicGolem.RUNE_EVERY_TURN + 8, "charge should shield 8 more")
	_check(names == ["Arcane Bolt", "Charge", "Overload", "Arcane Bolt", "Charge", "Overload"], "golem order: %s" % [names])
	_check(golem.actions[0].parts[0].tiles.size() == 6 and golem.actions[2].parts[0].tiles.size() == 14, "golem patterns should be 6 and 14 tiles")



func _check_dark_elf(combat: CombatState) -> void:
	var elf := DarkElf.new()
	combat.enemies = [elf]
	var player := combat.player

	# Poison Dart -> Shadow Step, looped. The dart damages its line and poisons the tile past its tip;
	# Shadow Step shields 5 of its own and damages its slash.
	var names: Array[String] = []
	for i in 4:
		_heal(player)
		_heal(elf)
		elf.plan(combat)
		var action := elf.intent_actions[0]
		names.append(action.action_name)
		var expect_damaged := {}
		var expect_poisoned := {}
		for t in action.parts[0].tiles:
			var cell: Vector2i = action.parts[0].cell + t.coords
			if not player.health.has(cell):
				continue
			if t is DamageTile:
				expect_damaged[cell] = true
			else:
				expect_poisoned[cell] = true
		await elf.take_turn(combat)
		var poisoned := player.health.keys().filter(func(c: Vector2i) -> bool: return player.health[c].has_effect(PoisonTileEffect))
		_check(_cells_with(player, Enum.HealthTileEnum.DAMAGED) == expect_damaged.size() and _all_in(player, expect_damaged, Enum.HealthTileEnum.DAMAGED),
			"%s didn't damage what its intent showed" % action.action_name)
		_check(poisoned.size() == expect_poisoned.size() and poisoned.all(func(c: Vector2i) -> bool: return expect_poisoned.has(c)),
			"%s didn't poison what its intent showed" % action.action_name)
		if action is DarkElfShadowStep:
			_check(_cells_with(elf, Enum.HealthTileEnum.SHIELDED) == DarkElfShadowStep.SHIELDS, "shadow step should shield %d" % DarkElfShadowStep.SHIELDS)
		else:
			_check(not expect_poisoned.is_empty(), "poison dart poisoned nothing")
	_check(names == ["Poison Dart", "Shadow Step", "Poison Dart", "Shadow Step"], "dark elf order: %s" % [names])



func _check_griffin(combat: CombatState) -> void:
	var griffin := Griffin.new()
	combat.enemies = [griffin]
	var player := combat.player

	# Talon (2 hits) -> Wing Gust -> Dive, looped. Each attack damages what its intent showed.
	var names: Array[String] = []
	for i in 6:
		_heal(player)
		_heal(griffin)
		griffin.plan(combat)
		var action := griffin.intent_actions[0]
		names.append(action.action_name)
		var expect := {}
		for part in action.parts:
			for cell in _covered(player, part):
				expect[cell] = true
		await griffin.take_turn(combat)
		if action is EnemyHit:
			_check(_cells_with(player, Enum.HealthTileEnum.DAMAGED) == expect.size(), "%s didn't damage what its intent showed" % action.action_name)
		else:
			_check(_cells_with(griffin, Enum.HealthTileEnum.SHIELDED) == 6, "wing gust should shield 6")
	_check(names == ["Talon", "Wing Gust", "Dive", "Talon", "Wing Gust", "Dive"], "griffin order: %s" % [names])
	_check(griffin.actions[0].parts[0].tiles.size() == 5 and griffin.actions[2].parts[0].tiles.size() == 9, "griffin patterns should be 5 and 9 tiles")

	# Aerial: the first 3 hits each player turn miss, even on a Shield or with Pierce; the 4th lands.
	# Hits during its own turn always land, and its turn end gets the 3 misses back.
	_check(griffin.power_amount(AerialPower) == Griffin.AERIAL, "griffin should start with Aerial %d" % Griffin.AERIAL)
	_heal(griffin)
	await griffin.on_turn_end(combat)
	var cells := griffin.health.keys()
	griffin.health[cells[0]].hp = Enum.HealthTileEnum.SHIELDED
	var landed: Array[bool] = []
	for i in 4:
		landed.append(griffin.damage_health_tile(combat, cells[i], i == 1))
	_check(landed == [false, false, false, true], "aerial hits: %s" % [landed])
	_check(griffin.health[cells[0]].hp == Enum.HealthTileEnum.SHIELDED, "aerial should keep the Shield")
	await griffin.on_turn_start(combat)
	_check(griffin.damage_health_tile(combat, cells[4]), "aerial cancelled a hit during its own turn")
	await griffin.on_turn_end(combat)
	_check(not griffin.damage_health_tile(combat, cells[5]), "aerial should miss again after its turn")



func _check_hydra(combat: CombatState) -> void:
	var hydra := Hydra.new()
	combat.enemies = [hydra]
	var player := combat.player
	var cells: Array = hydra.health.keys()
	_check(hydra.power_amount(MultiHeadPower) == 3 and hydra.power_amount(RegenPower) == 3, "hydra should start with 3 heads and Regen 3")

	# 9 lost tiles in the player's turn keep 3 heads; the 10th cuts one at once. The intent drops a bite,
	# keeps the other two where they were aimed, and stops counting. 10 more that turn cut nothing.
	_heal(player)
	hydra.plan(combat)
	var planned: Array = hydra.intent_actions[0].parts.map(func(p: EnemyActionPart) -> Vector2i: return p.cell)
	_check(_rows(hydra) == "Bite (0/10)" and planned.size() == 3, "3 heads should plan 3 bites: %s" % _rows(hydra))
	for i in 9:
		hydra.damage_health_tile(combat, cells[i])
	_check(hydra.power_amount(MultiHeadPower) == 3 and _rows(hydra) == "Bite (9/10)", "9 lost tiles: %s" % _rows(hydra))
	hydra.damage_health_tile(combat, cells[9])
	var bite := hydra.intent_actions[0]
	_check(hydra.power_amount(MultiHeadPower) == 2 and _rows(hydra) == "Bite", "10 lost tiles should cut a head: %s" % _rows(hydra))
	_check(bite.parts.size() == 2 and bite.parts[0].cell == planned[0] and bite.parts[1].cell == planned[1], "the cut bite moved the others")
	_check(hydra.idle_frames[0] == Hydra.ART[2], "the sprite should show 2 heads")
	for i in range(10, 20):
		hydra.damage_health_tile(combat, cells[i])
	_check(hydra.power_amount(MultiHeadPower) == 2, "a second head went in the same turn")

	# Lost 8+: no Regen. Then the 2 bites land where the intent showed.
	await hydra.on_turn_start(combat)
	_check(_cells_with(hydra, Enum.HealthTileEnum.DAMAGED) == 20, "regen healed after a heavy turn")
	var expect := {}
	for part in bite.parts:
		for cell in _covered(player, part):
			expect[cell] = true
	await hydra.take_turn(combat)
	_check(_cells_with(player, Enum.HealthTileEnum.DAMAGED) == expect.size(), "hydra bites didn't damage what the intent showed")
	await hydra.on_turn_end(combat)

	# A light turn: 3 lost, no cut, Regen heals 3. Hits during its own turn don't count.
	hydra.plan(combat)
	_check(_rows(hydra) == "Bite (0/10)" and hydra.intent_actions[0].parts.size() == 2, "2 heads next turn: %s" % _rows(hydra))
	for i in range(20, 23):
		hydra.damage_health_tile(combat, cells[i])
	await hydra.on_turn_start(combat)
	_check(_cells_with(hydra, Enum.HealthTileEnum.DAMAGED) == 20, "regen should heal 3 after a light turn")
	for i in range(30, 45):
		hydra.damage_health_tile(combat, cells[i])
	_check(hydra.power_amount(MultiHeadPower) == 2, "tiles lost in its own turn cut a head")
	await hydra.on_turn_end(combat)

	# Two more heavy turns leave no heads: no intent, no attack.
	_heal(hydra)
	for turn in 2:
		hydra.plan(combat)
		for i in 10:
			hydra.damage_health_tile(combat, cells[turn * 10 + i])
		await hydra.on_turn_start(combat)
		await hydra.on_turn_end(combat)
	hydra.plan(combat)
	_check(hydra.power_amount(MultiHeadPower) == 0 and hydra.intent_actions.is_empty(), "no heads should mean no intent")
	_check(hydra.idle_frames[0] == Hydra.ART[0], "the sprite should show no heads")
	_heal(player)
	await hydra.take_turn(combat)
	_check(_cells_with(player, Enum.HealthTileEnum.DAMAGED) == 0, "a headless hydra attacked")



func _check_skeleton(combat: CombatState) -> void:
	var skeleton := Skeleton.new()
	combat.enemies = [skeleton]
	var player := combat.player
	_check(_cells_with(skeleton, Enum.HealthTileEnum.SHIELDED) == Skeleton.BONE_ARMOR, "skeleton should start with %d shields" % Skeleton.BONE_ARMOR)

	# Bone Throw (2 hits) -> Rattle, looped.
	var names: Array[String] = []
	for i in 4:
		_heal(player)
		_heal(skeleton)
		skeleton.plan(combat)
		var action := skeleton.intent_actions[0]
		names.append(action.action_name)
		var expect := {}
		for part in action.parts:
			for cell in _covered(player, part):
				expect[cell] = true
		await skeleton.on_turn_start(combat)
		await skeleton.take_turn(combat)
		if action is SkeletonRattle:
			_check(_cells_with(skeleton, Enum.HealthTileEnum.SHIELDED) == 7 and skeleton.power_amount(RetaliatePower) == SkeletonRattle.RETALIATE,
				"rattle should shield 7 and give Retaliate 3")
		else:
			_check(_cells_with(player, Enum.HealthTileEnum.DAMAGED) == expect.size(), "bone throw didn't damage what its intent showed")
		await skeleton.on_turn_end(combat)
	_check(names == ["Bone Throw", "Rattle", "Bone Throw", "Rattle"], "skeleton order: %s" % [names])

	# Retaliate: a player hit on a Shield damages 3 player tiles; gone at its next turn start.
	_heal(player)
	_heal(skeleton)
	await skeleton.on_turn_start(combat)  # clears the Retaliate left from the loop's last Rattle
	await skeleton.actions[1].execute(combat, skeleton)
	await skeleton.on_turn_end(combat)
	var shielded: Vector2i = skeleton.health.keys().filter(func(c: Vector2i) -> bool: return skeleton.health[c].hp == Enum.HealthTileEnum.SHIELDED)[0]
	player.in_turn = true
	skeleton.damage_health_tile(combat, shielded)
	player.in_turn = false
	_check(_cells_with(player, Enum.HealthTileEnum.DAMAGED) == SkeletonRattle.RETALIATE, "retaliate should damage 3 player tiles")
	await skeleton.on_turn_start(combat)
	_check(skeleton.power_amount(RetaliatePower) == 0, "retaliate should end at its turn start")
	await skeleton.on_turn_end(combat)



func _check_bat(combat: CombatState) -> void:
	var bat := Bat.new()
	combat.enemies = [bat]
	var player := combat.player

	# Bite damages what its intent showed and heals 3 of its own; Screech puts Screech on the player.
	var names: Array[String] = []
	for i in 4:
		_heal(player)
		_heal(bat)
		player.statuses.clear()
		for cell in bat.health.keys().slice(0, 5):
			bat.health[cell].hp = Enum.HealthTileEnum.DAMAGED
		bat.plan(combat)
		var action := bat.intent_actions[0]
		names.append(action.action_name)
		var hit: Array = _covered(player, action.parts[0]) if not action.parts.is_empty() else []
		await bat.take_turn(combat)
		if action is BatBite:
			_check(_cells_with(player, Enum.HealthTileEnum.DAMAGED) == hit.size(), "bite didn't damage what its intent showed")
			_check(_cells_with(bat, Enum.HealthTileEnum.DAMAGED) == 5 - BatBite.HEAL, "bite should heal 3")
		else:
			_check(player.power_amount(ScreechPower) == 1, "screech should put Screech on the player")
	_check(names == ["Bite", "Screech", "Bite", "Screech"], "bat order: %s" % [names])

	# Screech doesn't stack, and the next turn draws 1 fewer, then it's gone.
	await bat.actions[1].execute(combat, bat)
	_check(player.power_amount(ScreechPower) == 1, "screech stacked")
	combat.discard_hand()
	var kept := combat.hand.size()  # Retain cards stay in hand
	await combat.start_turn()
	_check(combat.hand.size() - kept == CombatState.DRAW_PER_TURN - 1, "screech should draw %d, drew %d" % [CombatState.DRAW_PER_TURN - 1, combat.hand.size() - kept])
	_check(player.power_amount(ScreechPower) == 1, "screech should stay through the player's turn")
	await player.on_turn_end(combat)
	_check(player.power_amount(ScreechPower) == 0, "screech should go away when the player's turn ends")
	combat.discard_hand()
	kept = combat.hand.size()
	await combat.start_turn()
	_check(combat.hand.size() - kept == CombatState.DRAW_PER_TURN, "the turn after screech should draw normally, drew %d" % (combat.hand.size() - kept))
	await player.on_turn_end(combat)



func _check_zombie(combat: CombatState) -> void:
	var zombie := Zombie.new()
	combat.enemies = [zombie]
	var player := combat.player

	# Lumber -> Groan -> Rot Bite, looped. Rot Bite poisons the tiles past its ends.
	var names: Array[String] = []
	for i in 6:
		_heal(player)
		_heal(zombie)
		zombie.plan(combat)
		var action := zombie.intent_actions[0]
		names.append(action.action_name)
		var expect_damaged := {}
		var expect_poisoned := {}
		for part in action.parts:
			for t in part.tiles:
				var cell: Vector2i = part.cell + t.coords
				if player.health.has(cell):
					if t is DamageTile:
						expect_damaged[cell] = true
					else:
						expect_poisoned[cell] = true
		await zombie.take_turn(combat)
		if action is EnemyShieldSelf:
			_check(_cells_with(zombie, Enum.HealthTileEnum.SHIELDED) == 6, "groan should shield 6")
		else:
			var poisoned := player.health.keys().filter(func(c: Vector2i) -> bool: return player.health[c].has_effect(PoisonTileEffect))
			_check(_cells_with(player, Enum.HealthTileEnum.DAMAGED) == expect_damaged.size() and poisoned.size() == expect_poisoned.size(),
				"%s didn't match its intent" % action.action_name)
	_check(names == ["Lumber", "Groan", "Rot Bite", "Lumber", "Groan", "Rot Bite"], "zombie order: %s" % [names])

	# Rise: the first death brings back 12 tiles at once and uses it up; the second death is final.
	_heal(zombie)
	for cell in zombie.health:
		zombie.damage_health_tile(combat, cell)
	_check(not zombie.is_dead() and _cells_with(zombie, Enum.HealthTileEnum.UNDAMAGED) == Zombie.RISE and zombie.power_amount(RisePower) == 0,
		"zombie should rise with %d tiles" % Zombie.RISE)
	for cell in zombie.health:
		zombie.damage_health_tile(combat, cell)
	_check(zombie.is_dead(), "zombie rose twice")



func _check_frangenstein(combat: CombatState) -> void:
	var frank := Frangenstein.new()
	combat.enemies = [frank]
	var player := combat.player
	var plated := frank.health.values().filter(func(t: HealthTile) -> bool: return t.has_effect(PlateTileEffect)).size()
	_check(plated == Frangenstein.STITCHED, "frangenstein should start with %d Plate, has %d" % [Frangenstein.STITCHED, plated])

	# Thunder Fist -> Static (through Shield) -> Overcharge (Strength 2), then Overcharge stacks.
	var names: Array[String] = []
	for i in 3:
		_heal(player)
		for tile in player.health.values():
			tile.hp = Enum.HealthTileEnum.SHIELDED if i == 1 else Enum.HealthTileEnum.UNDAMAGED
		frank.plan(combat)
		var action := frank.intent_actions[0]
		names.append(action.action_name)
		var hit: Array = _covered(player, action.parts[0]) if not action.parts.is_empty() else []
		await frank.take_turn(combat)
		if action is EnemyApplyPower:
			_check(frank.power_amount(StrengthPower) == Frangenstein.OVERCHARGE, "overcharge should give Strength %d" % Frangenstein.OVERCHARGE)
		else:
			_check(not hit.is_empty() and hit.all(func(c: Vector2i) -> bool: return player.health[c].hp == Enum.HealthTileEnum.DAMAGED)
				and _cells_with(player, Enum.HealthTileEnum.DAMAGED) == hit.size(), "%s didn't damage what its intent showed" % action.action_name)
	_check(names == ["Thunder Fist", "Static", "Overcharge"], "frangenstein order: %s" % [names])
	_check(frank.actions[0].parts[0].tiles.size() == 15, "thunder fist should be 15 tiles")
	await frank.actions[2].execute(combat, frank)
	_check(frank.power_amount(StrengthPower) == 2 * Frangenstein.OVERCHARGE, "overcharge should stack")



func _check_jack(combat: CombatState) -> void:
	var jack := JackOLantern.new()
	combat.enemies = [jack]
	var player := combat.player

	# Flame Spit (with Poison) -> Grin (Strength 2) -> Pumpkin Smash. Patterns are 7 + 2 Poison and 11.
	var names: Array[String] = []
	for i in 2:
		_heal(player)
		jack.plan(combat)
		var action := jack.intent_actions[0]
		names.append(action.action_name)
		var hit: Array = []
		for part in action.parts:
			for t in part.tiles:
				if t is DamageTile and player.health.has(part.cell + t.coords):
					hit.append(part.cell + t.coords)
		await jack.take_turn(combat)
		if action is EnemyApplyPower:
			_check(jack.power_amount(StrengthPower) == JackOLantern.GRIN, "grin should give Strength %d" % JackOLantern.GRIN)
		else:
			_check(_cells_with(player, Enum.HealthTileEnum.DAMAGED) == hit.size(), "flame spit didn't damage what its intent showed")
	jack.plan(combat)
	names.append(jack.intent_actions[0].action_name)
	_check(names == ["Flame Spit", "Grin", "Pumpkin Smash"], "jack order: %s" % [names])
	_check(jack.actions[0].parts[0].tiles.size() == 9 and jack.actions[2].parts[0].tiles.size() == 11, "jack patterns should be 7 + 2 and 11 tiles")

	# Burning Head: the 6th tile one Attack card destroys burns 3 player tiles, once per card.
	# Non-Attack cards and hits outside a card don't count.
	var cells: Array = jack.health.keys()
	_heal(player)
	_heal(jack)
	combat.playing = Strike.new()
	for i in 5:
		jack.damage_health_tile(combat, cells[i])
	_check(_cells_with(player, Enum.HealthTileEnum.DAMAGED) == 0, "burning head burned before 6 tiles")
	jack.damage_health_tile(combat, cells[5])
	_check(_cells_with(player, Enum.HealthTileEnum.DAMAGED) == JackOLantern.BURN, "burning head should burn %d" % JackOLantern.BURN)
	for i in range(6, 14):
		jack.damage_health_tile(combat, cells[i])
	_check(_cells_with(player, Enum.HealthTileEnum.DAMAGED) == JackOLantern.BURN, "burning head burned twice for one card")
	combat.playing = Strike.new()
	for i in range(14, 20):
		jack.damage_health_tile(combat, cells[i])
	_check(_cells_with(player, Enum.HealthTileEnum.DAMAGED) == 2 * JackOLantern.BURN, "a new card should count again")
	combat.playing = ShieldPlayer.new()
	for i in range(20, 26):
		jack.damage_health_tile(combat, cells[i])
	combat.playing = null
	for i in range(26, 32):
		jack.damage_health_tile(combat, cells[i])
	_check(_cells_with(player, Enum.HealthTileEnum.DAMAGED) == 2 * JackOLantern.BURN, "only Attack cards should count")



func _check_lil_ghost(combat: CombatState) -> void:
	var ghost := LilGhost.new()
	combat.enemies = [ghost]
	var player := combat.player
	player.statuses.clear()

	# Boo (3 scattered hits) -> Shiver (on the player).
	var names: Array[String] = []
	for i in 2:
		_heal(player)
		ghost.plan(combat)
		var action := ghost.intent_actions[0]
		names.append(action.action_name)
		var expect := {}
		for part in action.parts:
			for cell in _covered(player, part):
				expect[cell] = true
		await ghost.take_turn(combat)
		if action is EnemyHit:
			_check(_cells_with(player, Enum.HealthTileEnum.DAMAGED) == expect.size(), "boo didn't damage what its intent showed")
		else:
			_check(player.power_amount(ShiverPower) == 1, "shiver should put Shiver on the player")
	_check(names == ["Boo", "Shiver"], "lil ghost order: %s" % [names])

	# Shiver: the next card costs 1 more, then it's gone. It doesn't stack, and ends with the player's turn.
	await ghost.actions[1].execute(combat, ghost)
	_check(player.power_amount(ShiverPower) == 1, "shiver stacked")
	var card := ShieldPlayer.new()
	combat.hand.append(card)
	combat.energy = card.cost
	_check(combat.cost_of(card) == card.cost + 1 and not combat.can_play(card), "shiver should add 1 to the cost")
	combat.energy = card.cost + 1
	_heal(player)
	await combat.play_card(card, [player], [player.health.keys()[0]], [0])
	_check(combat.energy == 0 and player.power_amount(ShiverPower) == 0, "shiver should be paid once, then gone")
	await ghost.actions[1].execute(combat, ghost)
	await player.on_turn_end(combat)
	_check(player.power_amount(ShiverPower) == 0, "shiver should end with the player's turn")
	# An X-cost card gets 1 less X under Shiver, spends all the energy, and uses Shiver up.
	await ghost.actions[1].execute(combat, ghost)
	combat.energy = 3
	var flurry := Flurry.new()
	combat.hand.append(flurry)
	_check(combat.x_energy() == 2 and flurry.clicks(combat.x_energy()) == 2, "shiver should take 1 off X")
	var targets: Array[CombatUnit] = [ghost, ghost]
	var cells: Array[Vector2i] = [ghost.health.keys()[0], ghost.health.keys()[1]]
	await combat.play_card(flurry, targets, cells, [0, 0])
	_check(combat.energy == 0 and player.power_amount(ShiverPower) == 0 and combat.x_energy() == 0, "an X-cost card should spend everything and use Shiver up")

	# Ethereal: one Attack card lands 5 hits, the rest miss; a new card starts over; other cards aren't capped.
	cells.assign(ghost.health.keys())
	_heal(ghost)
	combat.playing = Strike.new()
	var landed := 0
	for i in 8:
		if ghost.damage_health_tile(combat, cells[i]):
			landed += 1
	_check(landed == LilGhost.ETHEREAL, "ethereal should let %d hits land, let %d" % [LilGhost.ETHEREAL, landed])
	combat.playing = Strike.new()
	_check(ghost.damage_health_tile(combat, cells[8]), "a new card should hit again")
	combat.playing = ShieldPlayer.new()
	landed = 0
	for i in range(9, 17):
		if ghost.damage_health_tile(combat, cells[i]):
			landed += 1
	combat.playing = null
	_check(landed == 8, "ethereal capped a non-Attack card")



func _check_mummy(combat: CombatState) -> void:
	var mummy := Mummy.new()
	combat.enemies = [mummy]
	var player := combat.player
	player.statuses.clear()

	# Curse Wrap (on the player) -> Pierce (through Shield).
	var names: Array[String] = []
	for i in 2:
		_heal(player)
		for tile in player.health.values():
			tile.hp = Enum.HealthTileEnum.SHIELDED
		mummy.plan(combat)
		var action := mummy.intent_actions[0]
		names.append(action.action_name)
		var hit: Array = _covered(player, action.parts[0]) if not action.parts.is_empty() else []
		await mummy.take_turn(combat)
		if action is EnemyHit:
			_check(not hit.is_empty() and _cells_with(player, Enum.HealthTileEnum.DAMAGED) == hit.size(), "pierce didn't go through Shield where its intent showed")
		else:
			_check(player.power_amount(CurseWrapPower) == Mummy.CURSE_WRAP, "curse wrap should put Curse Wrap 3 on the player")
	_check(names == ["Curse Wrap", "Pierce"], "mummy order: %s" % [names])

	# Curse Wrap: during a Defense card, the first 3 Shields or Plates fizzle; other cards aren't affected;
	# it's gone after the Defense card, and at the end of the player's turn.
	_heal(player)
	var cells: Array = player.health.keys()
	combat.playing = Strike.new()
	player.shield_health_tile(combat, cells[0])
	combat.playing = ShieldPlayer.new()
	for i in range(1, 5):
		player.shield_health_tile(combat, cells[i])
	player.apply_effect_health_tile(combat, cells[5], PlateTileEffect.new())
	combat.playing = null
	_check(_cells_with(player, Enum.HealthTileEnum.SHIELDED) == 2 and player.health[cells[5]].has_effect(PlateTileEffect),
		"curse wrap should eat 3 Shields of the Defense card only")
	player.statuses.clear()  # used up outside play_card, so nothing took it off
	await mummy.actions[0].execute(combat, mummy)
	var card := ShieldPlayer.new()
	combat.hand.append(card)
	combat.energy = card.cost
	_heal(player)
	await combat.play_card(card, [player], [cells[0]], [0])
	_check(_cells_with(player, Enum.HealthTileEnum.SHIELDED) == 0 and player.power_amount(CurseWrapPower) == 0, "curse wrap should eat the card's Shield, then go")
	await mummy.actions[0].execute(combat, mummy)
	await player.on_turn_end(combat)
	_check(player.power_amount(CurseWrapPower) == 0, "curse wrap should end with the player's turn")

	# Wrapped: every other hit of the first Attack card misses; later cards land; it resets each turn.
	var tiles: Array = mummy.health.keys()
	_heal(mummy)
	combat.playing = Strike.new()
	var landed := 0
	for i in 6:
		if mummy.damage_health_tile(combat, tiles[i]):
			landed += 1
	_check(landed == 3, "wrapped should halve the first card, landed %d of 6" % landed)
	combat.playing = Strike.new()
	_check(mummy.damage_health_tile(combat, tiles[6]) and mummy.damage_health_tile(combat, tiles[7]), "wrapped should only halve the first card")
	combat.playing = null
	await mummy.on_turn_end(combat)
	combat.playing = Strike.new()
	landed = 0
	for i in range(8, 12):
		if mummy.damage_health_tile(combat, tiles[i]):
			landed += 1
	combat.playing = null
	_check(landed == 2, "wrapped should halve the first card again next turn")



func _check_warewolf(combat: CombatState) -> void:
	var wolf := Warewolf.new()
	combat.enemies = [wolf]
	var player := combat.player

	# Guard (Shield 10 + Hit 5, normal colour) -> Howl & Maul (Strength 1, then Hit 12, red), looped.
	var names: Array[String] = []
	for i in 4:
		_heal(player)
		_heal(wolf)
		wolf.plan(combat)
		var action := wolf.intent_actions[0]
		names.append(action.action_name)
		var hit := _covered(player, action.parts[0])
		var strength := wolf.power_amount(StrengthPower)
		_check(wolf.tint == (Warewolf.WOLF_TINT if action is WarewolfWolf else Color.WHITE), "warewolf tint doesn't match its form")
		var full := action is WarewolfWolf
		_check(wolf.power_amount(FullMoonPower) == int(full) and wolf.power_amount(NewMoonPower) == int(not full), "warewolf should have only %s" % ("Full Moon" if full else "New Moon"))
		await wolf.take_turn(combat)
		if action is WarewolfHuman:
			_check(_cells_with(wolf, Enum.HealthTileEnum.SHIELDED) == WarewolfHuman.SHIELDS, "guard should shield 10")
			_check(_cells_with(player, Enum.HealthTileEnum.DAMAGED) == hit.size(), "guard didn't damage what its intent showed")
		else:
			_check(wolf.power_amount(StrengthPower) == strength + WarewolfWolf.HOWL, "howl should give 1 Strength")
			_check(hit.all(func(c: Vector2i) -> bool: return player.health[c].hp == Enum.HealthTileEnum.DAMAGED), "maul missed its intent")
	_check(names == ["Guard", "Howl & Maul", "Guard", "Howl & Maul"], "warewolf order: %s" % [names])

	# Wolf form: the first hit of each Attack card also hits 3 more tiles. Not in Human form, not other cards.
	var cells: Array = wolf.health.keys()
	_heal(wolf)
	wolf.plan(combat)  # Guard: Human form
	combat.playing = Strike.new()
	wolf.damage_health_tile(combat, cells[0])
	_check(_cells_with(wolf, Enum.HealthTileEnum.DAMAGED) == 1, "human form took extra hits")
	wolf.plan(combat)  # Howl & Maul: Wolf form
	combat.playing = Strike.new()
	wolf.damage_health_tile(combat, cells[1])
	wolf.damage_health_tile(combat, wolf.health.keys().filter(func(c: Vector2i) -> bool: return wolf.health[c].hp == Enum.HealthTileEnum.UNDAMAGED)[0])
	_check(_cells_with(wolf, Enum.HealthTileEnum.DAMAGED) == 3 + FullMoonPower.EXTRA, "wolf form should add %d hits once per card" % FullMoonPower.EXTRA)
	var before := _cells_with(wolf, Enum.HealthTileEnum.DAMAGED)
	combat.playing = ShieldPlayer.new()
	wolf.damage_health_tile(combat, wolf.health.keys().filter(func(c: Vector2i) -> bool: return wolf.health[c].hp == Enum.HealthTileEnum.UNDAMAGED)[0])
	_check(_cells_with(wolf, Enum.HealthTileEnum.DAMAGED) == before + 1, "wolf form took extra hits from a non-Attack card")
	combat.playing = Strike.new()
	wolf.damage_health_tile(combat, wolf.health.keys().filter(func(c: Vector2i) -> bool: return wolf.health[c].hp == Enum.HealthTileEnum.UNDAMAGED)[0])
	combat.playing = null
	_check(_cells_with(wolf, Enum.HealthTileEnum.DAMAGED) == before + 2 + FullMoonPower.EXTRA, "a new Attack card should add the extra hits again")
	_check(not FullMoonPower.new().show_amount and not NewMoonPower.new().show_amount, "moon badges shouldn't show an amount")



func _check_dragon(combat: CombatState) -> void:
	var dragon := Dragon.new()
	combat.enemies = [dragon]
	var player := combat.player

	# P1 cycle.
	var names: Array[String] = []
	for i in 6:
		_heal(player)
		dragon.plan(combat)
		names.append(dragon.intent_actions[0].action_name)
		await dragon.take_turn(combat)
	_check(names == ["Claw", "Tail Sweep", "Fire Breath", "Claw", "Tail Sweep", "Fire Breath"], "dragon P1 order: %s" % [names])

	# Claw goes for open tiles before shielded ones.
	_heal(player)
	var cells := player.health.keys()
	for cell in cells.slice(0, 12):
		player.health[cell].hp = Enum.HealthTileEnum.SHIELDED
	var claw := dragon.actions[0]
	claw.plan(combat, dragon)
	var open := claw.parts[0].tiles.filter(func(t: BaseActionTile) -> bool: return player.health[t.coords].hp == Enum.HealthTileEnum.UNDAMAGED).size()
	_check(claw.parts[0].tiles.size() == 8 and open == 7, "claw should take all 7 open tiles first, took %d of %d" % [open, claw.parts[0].tiles.size()])

	# Tail Sweep: on open tiles the second row goes elsewhere; on shielded ones it follows the first.
	var sweep := dragon.actions[1]
	_heal(player)
	sweep.plan(combat, dragon)
	_check(_covered(player, sweep.parts[0]) != _covered(player, sweep.parts[1]), "tail sweep hit the same row twice on open tiles")
	for tile in player.health.values():
		tile.hp = Enum.HealthTileEnum.SHIELDED
	sweep.plan(combat, dragon)
	var first := _covered(player, sweep.parts[0])
	_check(first == _covered(player, sweep.parts[1]), "tail sweep should follow up on the shielded row")
	await sweep.execute(combat, dragon)
	_check(first.all(func(c: Vector2i) -> bool: return player.health[c].hp == Enum.HealthTileEnum.DAMAGED), "tail sweep x2 didn't damage the shielded row")

	# Inferno pierces Shield.
	for tile in player.health.values():
		tile.hp = Enum.HealthTileEnum.SHIELDED
	var inferno := dragon.actions[3]
	inferno.plan(combat, dragon)
	await inferno.execute(combat, dragon)
	var burnt := _covered(player, inferno.parts[0])
	_check(not burnt.is_empty() and burnt.all(func(c: Vector2i) -> bool: return player.health[c].hp == Enum.HealthTileEnum.DAMAGED), "inferno didn't pierce Shield")

	# P2 starts below half the tiles: 45 of 90 undamaged is still P1, 44 is P2.
	var tiles := dragon.health.values()
	for i in 45:
		tiles[i].hp = Enum.HealthTileEnum.DAMAGED
	dragon.plan(combat)
	_check(not dragon.in_p2, "dragon in P2 at exactly half its tiles")
	tiles[45].hp = Enum.HealthTileEnum.DAMAGED
	names.clear()
	for i in 5:
		_heal(player)
		dragon.plan(combat)
		names.append(dragon.intent_actions[0].action_name)
		await dragon.take_turn(combat)
	_check(names == ["Claw", "Inferno", "Tail Sweep", "Inferno", "Claw"], "dragon P2 order: %s" % [names])



func _check_dracula(combat: CombatState) -> void:
	var dracula := Dracula.new()
	combat.enemies = [dracula]
	var player := combat.player

	# P1 cycle, by index so the two Bites (heal 4 / heal 8) are told apart.
	var order: Array[int] = []
	for i in 4:
		_heal(player)
		dracula.plan(combat)
		order.append(dracula.actions.find(dracula.intent_actions[0]))
		await dracula.take_turn(combat)
	_check(order == [0, 1, 2, 0], "dracula P1 order: %s" % [order])

	# Bite heals 4 of its own damaged tiles, 8 in P2.
	for bite: DraculaBite in [dracula.actions[0], dracula.actions[3]]:
		_heal(player)
		_heal(dracula)
		var tiles := dracula.health.values()
		for i in 10:
			tiles[i].hp = Enum.HealthTileEnum.DAMAGED
		bite.plan(combat, dracula)
		await bite.execute(combat, dracula)
		_check(_cells_with(dracula, Enum.HealthTileEnum.DAMAGED) == 10 - bite.heal, "bite should heal %d" % bite.heal)

	# Blood Mist shields 10 of its own tiles.
	_heal(dracula)
	await dracula.actions[2].execute(combat, dracula)
	_check(_cells_with(dracula, Enum.HealthTileEnum.SHIELDED) == 10, "blood mist should shield 10")

	# Bat Swarm and Crimson Rain land every hit on a tile that isn't damaged yet.
	for scattered in [dracula.actions[1], dracula.actions[4]]:
		for i in 20:
			_heal(player)
			for cell in player.health.keys().slice(0, 12):
				player.health[cell].hp = Enum.HealthTileEnum.DAMAGED
			scattered.plan(combat, dracula)
			for part in scattered.parts:
				_check(_covered(player, part).any(func(c: Vector2i) -> bool: return player.health[c].hp > Enum.HealthTileEnum.DAMAGED),
					"%s put a hit where nothing is left" % scattered.action_name)

	# Each hit plays on its own: one animated batch per bat and per wave.
	for scattered in [dracula.actions[1], dracula.actions[4]]:
		_heal(player)
		var batches := []
		combat.animator = func(batch: Array[Dictionary]) -> void: batches.append(batch)
		scattered.plan(combat, dracula)
		await scattered.execute(combat, dracula)
		combat.animator = Callable()
		_check(batches.size() == scattered.parts.size(), "%s played %d hits, not %d" % [scattered.action_name, batches.size(), scattered.parts.size()])

	# P2 below half its tiles.
	_heal(dracula)
	var tiles := dracula.health.values()
	for i in 66:
		tiles[i].hp = Enum.HealthTileEnum.DAMAGED
	order.clear()
	for i in 4:
		_heal(player)
		dracula.plan(combat)
		order.append(dracula.actions.find(dracula.intent_actions[0]))
		await dracula.take_turn(combat)
		for t in tiles.slice(0, 66):  # keep it below half despite the Bite heals
			t.hp = Enum.HealthTileEnum.DAMAGED
	_check(order == [3, 4, 2, 3], "dracula P2 order: %s" % [order])



func _check_ramiel(combat: CombatState) -> void:
	var player := combat.player
	var ramiel := Ramiel.new()
	combat.enemies = [ramiel]
	_check(RamielField.shields(ramiel) == 20, "ramiel should start with 20 shields")

	# P1: Scan -> Charge x3 (counting down, beam locked) -> Particle Beam (Pierce) -> Scan.
	var turns: Array[String] = []
	var locked := Vector2i.ZERO
	for i in 6:
		_heal(player)
		ramiel.plan(combat)
		turns.append(_rows(ramiel))
		var charge := ramiel.intent_actions.filter(func(a: BaseEnemyAction) -> bool: return a is RamielCharge)
		if i == 1:
			locked = charge[0].parts[0].cell
		elif not charge.is_empty():
			_check(charge[0].parts[0].cell == locked, "charge %d moved the beam" % i)
		if i == 4:
			for tile in player.health.values():
				tile.hp = Enum.HealthTileEnum.SHIELDED
			var beam: RamielParticleBeam = ramiel.intent_actions.back()
			_check(beam.parts[0].cell == locked, "beam didn't fire where the charges aimed")
			await ramiel.take_turn(combat)
			var burnt := _covered(player, beam.parts[0])
			_check(not burnt.is_empty() and burnt.all(func(c: Vector2i) -> bool: return player.health[c].hp == Enum.HealthTileEnum.DAMAGED), "beam didn't pierce Shield")
		else:
			await ramiel.take_turn(combat)
	_check(turns == ["Scan", "Charge: 3 turns (0/20)", "Charge: 2 turns (0/20)",
		"Charge: 1 turn (0/20)", "Particle Beam", "Scan"], "ramiel P1 turns: %s" % [turns])

	# Interrupt: 19 lost tiles don't, the 20th turns the Charge into Stunned at once; then it starts over.
	ramiel = Ramiel.new()
	combat.enemies = [ramiel]
	for i in 2:
		ramiel.plan(combat)
		if i == 0:
			await ramiel.take_turn(combat)
	var open: Array = ramiel.health.keys()
	for i in 19:
		ramiel.damage_health_tile(combat, open[i], true)
	_check(_rows(ramiel) == "Charge: 3 turns (19/20)", "19 lost tiles: %s" % _rows(ramiel))
	ramiel.damage_health_tile(combat, open[19], true)
	_check(_rows(ramiel) == "Stunned", "20 lost tiles should stun, got %s" % _rows(ramiel))
	_heal(player)
	await ramiel.take_turn(combat)
	_check(_cells_with(player, Enum.HealthTileEnum.DAMAGED) == 0, "a stunned ramiel attacked")
	ramiel.plan(combat)
	_check(_rows(ramiel) == "Scan", "after the stun the cycle should start over, got %s" % _rows(ramiel))

	# P2 from a cycle boundary: Charge x2 with a Shard Drill each -> Particle Beam.
	ramiel = Ramiel.new()
	combat.enemies = [ramiel]
	var tiles := ramiel.health.values()
	for i in 86:
		tiles[i].hp = Enum.HealthTileEnum.DAMAGED
	turns.clear()
	for i in 4:
		_heal(player)
		ramiel.plan(combat)
		turns.append(_rows(ramiel).replace("Absolute Terror Field\n", ""))
		await ramiel.take_turn(combat)
	_check(turns == ["Charge: 2 turns (0/20)\nShard Drill", "Charge: 1 turn (0/20)\nShard Drill",
		"Particle Beam", "Charge: 2 turns (0/20)\nShard Drill"], "ramiel P2 turns: %s" % [turns])

	# Field: every 3rd turn, first in the turn; marked tiles destroyed before it runs stay unshielded.
	ramiel = Ramiel.new()
	combat.enemies = [ramiel]
	var shielded: Array = ramiel.health.keys().filter(func(c: Vector2i) -> bool: return ramiel.health[c].hp == Enum.HealthTileEnum.SHIELDED)
	for cell in shielded.slice(5):
		ramiel.health[cell].hp = Enum.HealthTileEnum.UNDAMAGED
	ramiel._turns = 2
	ramiel._step = 1  # a Charge turn, so no Scan joins in
	ramiel.plan(combat)
	var field: BaseEnemyAction = ramiel.intent_actions[0]
	_check(field is RamielField and field.parts[0].tiles.size() == 15, "field should plan 15 tiles first in the turn")
	for t in field.parts[0].tiles.slice(0, 2):
		ramiel.health[t.coords].hp = Enum.HealthTileEnum.DAMAGED
	await ramiel.take_turn(combat)
	_check(RamielField.shields(ramiel) == 18, "field should shield 13 surviving marks, has %d shields" % RamielField.shields(ramiel))
	# At 20 Shields it's skipped, but the turn still counts.
	ramiel._turns = 5
	for cell in ramiel.health:
		if RamielField.shields(ramiel) < 20 and ramiel.health[cell].hp == Enum.HealthTileEnum.UNDAMAGED:
			ramiel.health[cell].hp = Enum.HealthTileEnum.SHIELDED
	ramiel.plan(combat)
	_check(not _rows(ramiel).contains("Absolute Terror Field") and ramiel._turns == 6, "field at 20 shields should be skipped")
	# Field + Scan on the same turn: 20, then 15 more.
	ramiel = Ramiel.new()
	combat.enemies = [ramiel]
	for cell in ramiel.health:
		if ramiel.health[cell].hp == Enum.HealthTileEnum.SHIELDED:
			ramiel.health[cell].hp = Enum.HealthTileEnum.UNDAMAGED
	ramiel._turns = 2
	ramiel.plan(combat)
	_check(_rows(ramiel) == "Absolute Terror Field\nScan", "field + scan rows: %s" % _rows(ramiel))
	await ramiel.take_turn(combat)
	_check(RamielField.shields(ramiel) == 35, "field + scan should make 35 shields, has %d" % RamielField.shields(ramiel))


## A unit's intent label: one row per move.
func _rows(enemy: BaseEnemy) -> String:
	return "\n".join(PackedStringArray(enemy.intent_actions.map(func(a: BaseEnemyAction) -> String: return a.intent_text())))


## Cells of unit's grid that a planned part covers.
func _covered(unit: CombatUnit, part: EnemyActionPart) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for t in part.tiles:
		if unit.health.has(part.cell + t.coords):
			cells.append(part.cell + t.coords)
	cells.sort()
	return cells


func _check(ok: bool, msg: String) -> void:
	if not ok:
		_failures += 1
		printerr("FAIL: ", msg)


func _heal(unit: CombatUnit) -> void:
	for tile in unit.health.values():
		tile.hp = Enum.HealthTileEnum.UNDAMAGED
		tile.status_effects.clear()


func _cells_with(unit: CombatUnit, hp: int) -> int:
	return unit.health.values().filter(func(t: HealthTile) -> bool: return t.hp == hp).size()


func _all_in(unit: CombatUnit, cells: Dictionary, hp: int) -> bool:
	for cell in cells:
		if unit.health[cell].hp != hp:
			return false
	return true
