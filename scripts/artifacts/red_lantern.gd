class_name RedLantern
extends BaseArtifact

const EVERY := 3

func _init() -> void:
	super("Red Lantern", "Every %d turns, draw 1 card." % EVERY, Enum.ArtifactRarity.UNCOMMON, preload("res://assets/artifacts/red_lantern.png"))

func on_trigger(trigger: Enum.Trigger, combat: CombatState, _unit: CombatUnit, _cell: Vector2i) -> void:
	if trigger == Enum.Trigger.TURN_START and combat.turn % EVERY == 0:
		combat.draw(1)
