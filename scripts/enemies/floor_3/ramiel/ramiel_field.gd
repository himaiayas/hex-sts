class_name RamielField
extends BaseEnemyAction

## Absolute Terror Field: tops Ramiel's Shields back up to SHIELDS. The tiles are picked when it's
## planned and marked as its intent; when it runs, only the marked tiles still undamaged get Shield.

const SHIELDS := 20


func _init() -> void:
	super(Enum.BaseEnemyActionEnum.DEFEND, "Absolute Terror Field", 1.0)
	parts = [EnemyActionPart.new(Enum.Side.SELF, [])]


static func shields(unit: CombatUnit) -> int:
	return unit.health.values().filter(func(t: HealthTile) -> bool: return t.hp == Enum.HealthTileEnum.SHIELDED).size()


func plan(_combat: CombatState, owner: CombatUnit) -> void:
	var open: Array = owner.health.keys().filter(func(c: Vector2i) -> bool: return owner.health[c].hp == Enum.HealthTileEnum.UNDAMAGED)
	open.shuffle()
	parts[0].cell = Vector2i.ZERO
	parts[0].tiles = []
	for cell: Vector2i in open.slice(0, SHIELDS - shields(owner)):
		parts[0].tiles.append(ShieldTile.new(cell))


func execute(combat: CombatState, owner: CombatUnit) -> void:
	await GridAction.new(Enum.TargetType.ENEMY, parts[0].tiles).execute(combat, owner, Vector2i.ZERO)
