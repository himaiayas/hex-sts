class_name SlimeGuardedBash
extends BaseEnemyAction
## Attacks one player cell and shields one of its own cells in the same turn.
func _init(_probability: float) -> void:
    super(BaseEnemyActionEnum.ATTACK, "Guarded Bash", _probability)
    parts = [
        EnemyActionPart.new(EnemyActionPart.Side.PLAYER, [
            DamageTile.new(Vector2i(0,0)),
        ]),
        EnemyActionPart.new(EnemyActionPart.Side.SELF, [
            ShieldTile.new(Vector2i(0,0)),
        ]),
    ]

func execute(combat: CombatState, owner: CombatUnit) -> void:
    GridAction.new(BaseAction.TargetType.PLAYER, parts[0].tiles).execute(combat, combat.player, parts[0].cell)
    GridAction.new(BaseAction.TargetType.ENEMY, parts[1].tiles).execute(combat, owner, parts[1].cell)