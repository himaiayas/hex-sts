class_name DragonFang
extends BaseArtifact


func _init() -> void:
	super("Dragon Fang", "Whenever one of your tiles gains Fracture, gain 1 Strength (at most 2 each combat).", Enum.ArtifactRarity.LEGENDARY)

const MAX_STRENGTH := 2

var _combat: CombatState  # the fight the count is for
var _given := 0


func on_tile_effect_gained(combat: CombatState, _cell: Vector2i, effect: BaseTileEffect) -> void:
	if not effect is FractureTileEffect:
		return
	if combat != _combat:
		_combat = combat
		_given = 0
	if _given < MAX_STRENGTH:
		_given += 1
		combat.player.add_power(combat, StrengthPower.new(1))
