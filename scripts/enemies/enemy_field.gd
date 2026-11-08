class_name EnemyField
extends BaseEnemyAction

## Tops the enemy's Shields back up to amount (Ramiel's Absolute Terror Field, Mech Walker's Armor Plating).
## The tiles are picked when it's planned and marked as its intent; when it runs, only the marked
## tiles still undamaged get Shield.

var amount: int


func _init(_name: String, _amount: int) -> void:
	super(Enum.BaseEnemyActionEnum.DEFEND, _name, 1.0)
	amount = _amount
	description = "Shield its own tiles until it has %d Shields." % amount
	parts = [EnemyActionPart.new(Enum.Side.SELF, [])]


static func shields(unit: CombatUnit) -> int:
	return unit.health.values().filter(func(t: HealthTile) -> bool: return t.hp == Enum.HealthTileEnum.SHIELDED).size()


## Shields amount random tiles of unit, for its starting Shields.
static func shield_start(unit: CombatUnit, count: int) -> void:
	var cells := unit.health.keys()
	cells.shuffle()
	for cell in cells.slice(0, count):
		unit.health[cell].hp = Enum.HealthTileEnum.SHIELDED


func plan(_combat: CombatState, owner: CombatUnit) -> void:
	var open: Array = owner.health.keys().filter(func(c: Vector2i) -> bool: return owner.health[c].hp == Enum.HealthTileEnum.UNDAMAGED)
	open.shuffle()
	parts[0].cell = Vector2i.ZERO
	parts[0].tiles = []
	for cell: Vector2i in open.slice(0, amount - shields(owner)):
		parts[0].tiles.append(ShieldTile.new(cell))


func execute(combat: CombatState, owner: CombatUnit) -> void:
	await GridAction.new(Enum.TargetType.ENEMY, parts[0].tiles).execute(combat, owner, Vector2i.ZERO)
