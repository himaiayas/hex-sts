class_name Ramiel
extends BaseEnemy

## Floor 3, Boss. P1 cycles Scan -> Charge x3 -> Particle Beam. Below half its tiles (P2, from the
## next cycle) it cycles Charge x2 -> Particle Beam, with a Shard Drill on every Charge turn.
## Losing RamielCharge.INTERRUPT tiles from the first Charge until the beam turns the Charge into a Stunned turn,
## and the cycle starts over. Absolute Terror Field: starts with 20 Shields and tops them back up
## every 3rd turn, before its move.

const FIELD_EVERY := 3
const P1_CHARGES := 3
const P2_CHARGES := 2

var _counting := false  # from the first Charge until the beam is planned
var _step := 0  # turns into the current cycle
var _turns := 0  # turns planned, for the Field

var _field := RamielField.new()
var _scan := EnemyShieldSelf.new("Scan", 15)
var _charge := RamielCharge.new()
var _beam := RamielParticleBeam.new(_charge)
var _drill := RamielShardDrill.new()
var _stunned := RamielStunned.new()


func _init() -> void:
	var coords: Array[Vector2i] = [
		Vector2i(5, -11),
		Vector2i(4, -10), Vector2i(5, -10), Vector2i(6, -10),
		Vector2i(3, -9), Vector2i(4, -9), Vector2i(5, -9), Vector2i(6, -9),
		Vector2i(2, -8), Vector2i(3, -8), Vector2i(4, -8), Vector2i(5, -8), Vector2i(6, -8),
		Vector2i(1, -7), Vector2i(2, -7), Vector2i(3, -7), Vector2i(4, -7), Vector2i(5, -7), Vector2i(6, -7),
		Vector2i(0, -6), Vector2i(1, -6), Vector2i(2, -6), Vector2i(3, -6), Vector2i(4, -6), Vector2i(5, -6), Vector2i(6, -6),
		Vector2i(-1, -5), Vector2i(0, -5), Vector2i(1, -5), Vector2i(2, -5), Vector2i(3, -5), Vector2i(4, -5), Vector2i(5, -5), Vector2i(6, -5),
		Vector2i(-2, -4), Vector2i(-1, -4), Vector2i(0, -4), Vector2i(1, -4), Vector2i(2, -4), Vector2i(3, -4), Vector2i(4, -4), Vector2i(5, -4), Vector2i(6, -4),
		Vector2i(-3, -3), Vector2i(-2, -3), Vector2i(-1, -3), Vector2i(0, -3), Vector2i(1, -3), Vector2i(2, -3), Vector2i(3, -3), Vector2i(4, -3), Vector2i(5, -3), Vector2i(6, -3),
		Vector2i(-4, -2), Vector2i(-3, -2), Vector2i(-2, -2), Vector2i(-1, -2), Vector2i(0, -2), Vector2i(1, -2), Vector2i(2, -2), Vector2i(3, -2), Vector2i(4, -2), Vector2i(5, -2), Vector2i(6, -2),
		Vector2i(-6, -1), Vector2i(-5, -1), Vector2i(-4, -1), Vector2i(-3, -1), Vector2i(-2, -1), Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1), Vector2i(2, -1), Vector2i(3, -1), Vector2i(4, -1), Vector2i(5, -1), Vector2i(6, -1), Vector2i(7, -1),
		Vector2i(-7, 0), Vector2i(-6, 0), Vector2i(-5, 0), Vector2i(-4, 0), Vector2i(-3, 0), Vector2i(-2, 0), Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0), Vector2i(4, 0), Vector2i(5, 0), Vector2i(6, 0), Vector2i(7, 0),
		Vector2i(-7, 1), Vector2i(-6, 1), Vector2i(-5, 1), Vector2i(-4, 1), Vector2i(-3, 1), Vector2i(-2, 1), Vector2i(-1, 1), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1), Vector2i(4, 1), Vector2i(5, 1), Vector2i(6, 1),
		Vector2i(-6, 2), Vector2i(-5, 2), Vector2i(-4, 2), Vector2i(-3, 2), Vector2i(-2, 2), Vector2i(-1, 2), Vector2i(0, 2), Vector2i(1, 2), Vector2i(2, 2), Vector2i(3, 2), Vector2i(4, 2),
		Vector2i(-6, 3), Vector2i(-5, 3), Vector2i(-4, 3), Vector2i(-3, 3), Vector2i(-2, 3), Vector2i(-1, 3), Vector2i(0, 3), Vector2i(1, 3), Vector2i(2, 3), Vector2i(3, 3),
		Vector2i(-6, 4), Vector2i(-5, 4), Vector2i(-4, 4), Vector2i(-3, 4), Vector2i(-2, 4), Vector2i(-1, 4), Vector2i(0, 4), Vector2i(1, 4), Vector2i(2, 4),
		Vector2i(-6, 5), Vector2i(-5, 5), Vector2i(-4, 5), Vector2i(-3, 5), Vector2i(-2, 5), Vector2i(-1, 5), Vector2i(0, 5), Vector2i(1, 5),
		Vector2i(-6, 6), Vector2i(-5, 6), Vector2i(-4, 6), Vector2i(-3, 6), Vector2i(-2, 6), Vector2i(-1, 6), Vector2i(0, 6),
		Vector2i(-6, 7), Vector2i(-5, 7), Vector2i(-4, 7), Vector2i(-3, 7), Vector2i(-2, 7), Vector2i(-1, 7),
		Vector2i(-6, 8), Vector2i(-5, 8), Vector2i(-4, 8), Vector2i(-3, 8), Vector2i(-2, 8),
		Vector2i(-6, 9), Vector2i(-5, 9), Vector2i(-4, 9), Vector2i(-3, 9),
		Vector2i(-6, 10), Vector2i(-5, 10), Vector2i(-4, 10),
	]
	super("Ramiel", CombatUnit.make_hex_health(coords))
	idle_frames = [
		preload("res://assets/enemies/floor_3/ramiel_idle1.png"),
		preload("res://assets/enemies/floor_3/ramiel_idle2.png"),
		preload("res://assets/enemies/floor_3/ramiel_idle3.png"),
	]
	image_size = Vector2(450, 450)  # 1.5x the default
	# The scan art's inner ring, the only whole one.
	var ring := AtlasTexture.new()
	ring.atlas = preload("res://assets/enemies/floor_3/ramiel_scan.png")
	ring.region = Rect2(822, 332, 752, 330)
	_scan.ripple_vfx = ring
	# Aimed at the player from the first Charge until the beam fires.
	_charge.aim_vfx = preload("res://assets/enemies/floor_3/ramiel_charge.png")
	_beam.aim_vfx = _charge.aim_vfx
	actions = [_field, _scan, _charge, _beam, _drill, _stunned]
	var cells := health.keys()
	cells.shuffle()
	for cell in cells.slice(0, RamielField.SHIELDS):
		health[cell].hp = Enum.HealthTileEnum.SHIELDED


func _choose_actions() -> Array[BaseEnemyAction]:
	_turns += 1
	var rows: Array[BaseEnemyAction] = []
	if _turns % FIELD_EVERY == 0 and RamielField.shields(self) < RamielField.SHIELDS:
		rows.append(_field)
	var undamaged := health.values().filter(func(t: HealthTile) -> bool: return t.hp > Enum.HealthTileEnum.DAMAGED).size()
	if _step == 0 and undamaged * 2 < health.size():
		in_p2 = true
	var scans := 0 if in_p2 else 1
	var charges := P2_CHARGES if in_p2 else P1_CHARGES
	if _step < scans:
		rows.append(_scan)
	elif _step < scans + charges:
		if not _counting:
			_counting = true
			_charge.damage = 0
			_charge.locked = false
		_charge.turns_left = scans + charges - _step
		rows.append(_charge)
		if in_p2:
			rows.append(_drill)
	else:
		_counting = false
		rows.append(_beam)
	_step = (_step + 1) % (scans + charges + 1)
	return rows


## Counts the tiles lost while charging, and interrupts at RamielCharge.INTERRUPT, even mid-turn.
func fire_at(trigger: Enum.Trigger, combat: CombatState, cell: Vector2i) -> void:
	super(trigger, combat, cell)
	if trigger == Enum.Trigger.ON_HIT and _counting:
		_charge.damage += 1
		if _charge.damage >= RamielCharge.INTERRUPT:
			_interrupt()


## The Charge (and its Shard Drill) becomes Stunned; a planned Field still restores.
## The next turn starts the cycle over.
func _interrupt() -> void:
	_counting = false
	_step = 0
	var rows: Array[BaseEnemyAction] = []
	if _field in intent_actions:
		rows.append(_field)
	rows.append(_stunned)
	intent_actions = rows
