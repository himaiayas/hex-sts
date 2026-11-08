class_name EnemyHit
extends BaseEnemyAction

## Hit X: tiles is the pattern, played times times on the player's grid, one after another.
## A single hit goes where it scores best unless scattered; repeated hits are always scattered
## so they don't all land on the same best spot. Pierce goes in the tiles (DamageTile's flag).

var scattered: bool
var aimed := false  # an EnemyWindUp already locked the cell, so plan() leaves it


func _init(_name: String, _description: String, tiles: Array[BaseActionTile], times := 1, _scattered := false) -> void:
	super(Enum.BaseEnemyActionEnum.ATTACK, _name, 1.0)
	description = _description
	scattered = _scattered or times > 1
	for i in times:
		parts.append(EnemyActionPart.new(Enum.Side.PLAYER, tiles))


func plan(combat: CombatState, owner: CombatUnit) -> void:
	if not aimed:
		super(combat, owner)


func pick_cell(part: EnemyActionPart, target: CombatUnit) -> Vector2i:
	return pick_random_cell(part, target) if scattered else super(part, target)


func execute(combat: CombatState, _owner: CombatUnit) -> void:
	for part in parts:
		await GridAction.new(Enum.TargetType.PLAYER, part.tiles).execute(combat, combat.player, part.cell)
