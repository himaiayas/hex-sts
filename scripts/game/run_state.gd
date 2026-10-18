extends Node

## Data that lasts for the whole run (autoload "RunState").



var health:Array[Array] #Matrix with element as HealthTile
var gold := 0
var deck: Array[BaseCard] = []

## Non-null only during a fight.
var combat: CombatState = null


func start_new_run() -> void:
	health = CombatUnit.make_hex_health(2)
	gold = 0
	deck = []
	for i in 8:
		deck.append(Strike.new())


func start_combat() -> CombatState:
	combat = CombatState.new(self)
	return combat


func end_combat() -> void:
	if combat:
		combat.finish(self)
	combat = null
