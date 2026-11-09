class_name RamielParticleShards
extends BaseEnemyAction

## Hit HITS (P1, on Charge turns): HITS random undamaged tiles of the player (normal hits, so Shield
## still blocks them). The tiles are picked when the move is planned, so the intent shows them; any the
## player loses before it fires are swapped for other undamaged tiles, so no hit lands on a lost tile.

const HITS := 5


func _init() -> void:
	super(Enum.BaseEnemyActionEnum.ATTACK, "Particle Shards", 1.0)
	description = "Hit %d random tiles of yours that aren't damaged." % HITS
	parts = [EnemyActionPart.new(Enum.Side.PLAYER, [])]


func plan(combat: CombatState, _owner: CombatUnit) -> void:
	var cells := _undamaged(combat.player)
	cells.shuffle()
	var tiles: Array[BaseActionTile] = []
	for cell: Vector2i in cells.slice(0, HITS):
		tiles.append(DamageTile.new(cell))
	parts[0].cell = Vector2i.ZERO
	parts[0].tiles = tiles


## The planned tiles that are still undamaged (moved with the part, if Taunt moved it), then random others.
func execute(combat: CombatState, _owner: CombatUnit) -> void:
	var player := combat.player
	var open := _undamaged(player)
	var cells: Array = parts[0].tiles.map(func(t: BaseActionTile) -> Vector2i: return parts[0].cell + t.coords) \
		.filter(func(c: Vector2i) -> bool: return c in open)
	var others: Array = open.filter(func(c: Vector2i) -> bool: return c not in cells)
	others.shuffle()
	cells.append_array(others)
	var tiles: Array[BaseActionTile] = []
	for cell: Vector2i in cells.slice(0, HITS):
		tiles.append(DamageTile.new(cell))
	await GridAction.new(Enum.TargetType.PLAYER, tiles).execute(combat, player, Vector2i.ZERO)


static func _undamaged(unit: CombatUnit) -> Array:
	return unit.health.keys().filter(func(c: Vector2i) -> bool: return unit.health[c].hp > Enum.HealthTileEnum.DAMAGED)
