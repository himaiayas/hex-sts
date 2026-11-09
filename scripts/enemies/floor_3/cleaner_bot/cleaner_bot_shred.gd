class_name CleanerBotShred
extends BaseEnemyAction

## Removes Plate from up to SHRED of the player's Plated tiles, marked in its intent when it's planned,
## then shields SHIELDS random tiles of its own.

const SHRED := 4
const SHIELDS := 5


func _init() -> void:
	super(Enum.BaseEnemyActionEnum.DEBUFF, "Shred", 1.0)
	add_own_effect(ShieldTile, SHIELDS)
	description = "Remove Plate from %d of your tiles, then Shield %d of its own." % [SHRED, SHIELDS]
	parts = [EnemyActionPart.new(Enum.Side.PLAYER, [])]


func plan(combat: CombatState, _owner: CombatUnit) -> void:
	var player := combat.player
	var plated: Array = player.health.keys().filter(func(c: Vector2i) -> bool: return player.health[c].has_effect(PlateTileEffect))
	plated.shuffle()
	parts[0].cell = Vector2i.ZERO
	parts[0].tiles = []
	for cell: Vector2i in plated.slice(0, SHRED):
		parts[0].tiles.append(ShredTile.new(cell))


func execute(combat: CombatState, owner: CombatUnit) -> void:
	await GridAction.new(Enum.TargetType.PLAYER, parts[0].tiles).execute(combat, combat.player, Vector2i.ZERO)
	await inflict_random_own(combat, owner, ShieldTile.new(Vector2i.ZERO), SHIELDS)
