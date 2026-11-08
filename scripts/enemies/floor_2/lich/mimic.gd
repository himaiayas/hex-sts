class_name Mimic
extends BaseEnemy

## The Lich's Phylactery: a 20-tile object with no moves, fought beside it. While it stands the Lich
## has Regen; destroying it takes the Regen away.

var _lich: WeakRef  # weak: the Lich holds the Mimic, so a strong ref back would keep both alive forever


func _init(lich: BaseEnemy) -> void:
	var coords: Array[Vector2i] = [Vector2i(3, -1)]  # a radius-2 hexagon and one more
	for q in range(-2, 3):
		for r in range(maxi(-2, -q - 2), mini(2, -q + 2) + 1):
			coords.append(Vector2i(q, r))
	super("Mimic", CombatUnit.make_hex_health(coords))
	sprite = preload("res://assets/enemies/floor_2/mimic.png")
	image_size = Vector2(150, 150)  # half the usual
	grid_scale = 0.5
	_lich = weakref(lich)


func fire_at(trigger: Enum.Trigger, combat: CombatState, cell: Vector2i) -> void:
	super(trigger, combat, cell)
	var lich: BaseEnemy = _lich.get_ref()
	if trigger == Enum.Trigger.ON_HIT and is_dead() and lich:
		lich.statuses.assign(lich.statuses.filter(func(p: BaseEffect) -> bool: return not p is RegenPower))
