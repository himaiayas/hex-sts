class_name SlimeGuardedBash
extends BaseEnemyAction
## Attacks one player cell and plates one of its own cells in the same turn.
func _init(_probability: float) -> void:
    super(Enum.BaseEnemyActionEnum.ATTACK, "Guarded Bash", _probability)
    description = "Hit 1 tile and Plate 1 of its own tiles."
    parts = [
        EnemyActionPart.new(Enum.Side.PLAYER, [
            DamageTile.new(Vector2i(0,0)),
        ]),
        EnemyActionPart.new(Enum.Side.SELF, [
            ApplyEffectTile.new(Vector2i(0,0), PlateTileEffect.new()),
        ]),
    ]

func execute(combat: CombatState, owner: CombatUnit) -> void:
    await GridAction.new(Enum.TargetType.PLAYER, parts[0].tiles).execute(combat, combat.player, parts[0].cell)
    await GridAction.new(Enum.TargetType.ENEMY, parts[1].tiles).execute(combat, owner, parts[1].cell)