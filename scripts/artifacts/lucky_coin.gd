class_name LuckyCoin
extends BaseArtifact


func _init() -> void:
	super("Lucky Coin", "At the start of combat, draw 1 card.", Enum.ArtifactRarity.COMMON,
		preload("res://assets/artifacts/lucky_coin.png"))

func on_trigger(trigger: Enum.Trigger, combat: CombatState, _unit: CombatUnit, _cell: Vector2i) -> void:
	if trigger == Enum.Trigger.COMBAT_START:
		combat.draw(1)
