extends Node

## Data that lasts for the whole run (autoload "RunState").



var health:Dictionary[Vector2i, HealthTile] = {}
var gold := 0
var deck: Array[BaseCard] = []
var level :=0
var exp :=0
var floor :=1

## Non-null only during a fight.
var combat: CombatState = null


func start_new_run() -> void:
	health = CombatUnit.make_hex_health([
		Vector2i(0, 0), 
		Vector2i(1, 0), 
		Vector2i(0, 1), 
		Vector2i(-1, 1), 
		Vector2i(-1, 0), 
		Vector2i(0, -1), 
		Vector2i(1, -1),
		
	])
	gold = 0
	deck = []
	level = 0
	exp = 0
	floor = 1
	for i in 4:
		deck.append(Strike.new())
		deck.append(StatusStrike.new())
		deck.append(ShieldPlayer.new())
	for i in 2:
		deck.append(WomboCombo.new())


func start_combat() -> CombatState:
	combat = CombatState.new(self)
	return combat


func end_combat() -> void:
	if combat:
		combat.finish(self)
	combat = null
