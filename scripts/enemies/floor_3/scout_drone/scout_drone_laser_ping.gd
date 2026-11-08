class_name ScoutDroneLaserPing
extends EnemyHit

## Hit 6 x2 in lines. After a Scan, the first hit is a 2 x 5 band (Hit 10) on the spot the Scan
## locked, and only the second hit is aimed when it's planned.

var scanned: bool


func _init(_scanned: bool) -> void:
	var line: Array[BaseActionTile] = []
	for q in 6:
		line.append(DamageTile.new(Vector2i(q, 0)))
	super("Laser Ping", "Hit 6 tiles in a line 2 times.", line, 2)
	scanned = _scanned
	if scanned:
		var band: Array[BaseActionTile] = []
		for r in 2:
			for q in 5:
				band.append(DamageTile.new(Vector2i(q - floori(r / 2.0), r)))  # rows line up, not slant
		parts[0] = EnemyActionPart.new(Enum.Side.PLAYER, band)
		description = "Hit 10 tiles where it scanned, then 6 tiles in a line."


func plan(combat: CombatState, owner: CombatUnit) -> void:
	for part in parts.slice(1 if scanned else 0):
		part.cell = pick_cell(part, target_of(part, combat, owner))
