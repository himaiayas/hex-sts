extends Control

## Every artifact in ArtifactPool.ARTIFACTS, sorted by rarity then name: image, name, rarity and effect.

const TILE_SIZE := Vector2(270, 380)
const IMAGE_SIZE := 160
const RARITY_COLORS := {
	Enum.ArtifactRarity.COMMON: Color(0.75, 0.75, 0.75),
	Enum.ArtifactRarity.UNCOMMON: Color(0.4, 0.75, 1.0),
	Enum.ArtifactRarity.RARE: Color(1.0, 0.8, 0.3),
	Enum.ArtifactRarity.LEGENDARY: Color(1.0, 0.45, 0.85),
}

@onready var _grid: GridContainer = %Grid


func _ready() -> void:
	var artifacts: Array[BaseArtifact] = []
	for artifact_class in ArtifactPool.ARTIFACTS:
		artifacts.append(artifact_class.new())
	artifacts.sort_custom(func(a: BaseArtifact, b: BaseArtifact) -> bool:
		return a.rarity < b.rarity if a.rarity != b.rarity else a.name < b.name)
	for artifact in artifacts:
		_grid.add_child(_tile(artifact))


func _tile(artifact: BaseArtifact) -> Control:
	var color: Color = RARITY_COLORS.get(artifact.rarity, Color.WHITE)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = TILE_SIZE
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.13, 0.17)
	style.border_color = color
	style.set_border_width_all(3)
	style.set_corner_radius_all(12)
	style.set_content_margin_all(16)
	panel.add_theme_stylebox_override("panel", style)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	panel.add_child(box)

	var image := TextureRect.new()
	image.texture = artifact.image
	image.custom_minimum_size = Vector2(IMAGE_SIZE, IMAGE_SIZE)
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	box.add_child(image)

	var title := Label.new()
	title.text = artifact.name
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 24)
	box.add_child(title)

	var rarity := Label.new()
	rarity.text = Enum.ArtifactRarity.keys()[artifact.rarity].capitalize()
	rarity.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rarity.add_theme_color_override("font_color", color)
	rarity.add_theme_font_size_override("font_size", 18)
	box.add_child(rarity)

	var description := Label.new()
	description.text = artifact.description
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	description.add_theme_font_size_override("font_size", 17)
	description.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85))
	description.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(description)
	return panel
