extends Control

## Treasure chest: click to open, then a modal offers coins and a random artifact.
## Leave (only in the modal) collects the coins if not clicked; an artifact not clicked is left behind.

const GOLD := Vector2i(25, 45)  # [min, max]

@onready var _top_bar: TopBar = %TopBar
@onready var _chest: TextureButton = %Chest
@onready var _hint: Label = %Hint
@onready var _modal: ColorRect = %RewardModal
@onready var _gold_button: Button = %GoldButton
@onready var _artifact_button: Button = %ArtifactButton

var gold := 0
var artifact: BaseArtifact = null


func _on_chest_pressed() -> void:
	_chest.disabled = true  # shows the open texture
	_hint.hide()
	gold = randi_range(GOLD.x, GOLD.y)
	artifact = ArtifactPool.random_artifact(RunState.artifacts)
	_gold_button.text = "+%d Coins" % gold
	_artifact_button.visible = artifact != null
	if artifact:
		_artifact_button.text = artifact.name
		_artifact_button.tooltip_text = artifact.plain_description()
		_artifact_button.icon = artifact.image
	_modal.show()


func _on_gold_pressed() -> void:
	Sfx.play("coins")
	RunState.gold += gold
	_gold_button.hide()
	_top_bar.refresh()


func _on_artifact_pressed() -> void:
	RunState.add_artifact(artifact)
	_artifact_button.hide()
	_top_bar.refresh()


func _on_leave_pressed() -> void:
	if _gold_button.visible:
		_on_gold_pressed()
	RunState.leave_room()
