class_name MutationSelection
extends Control

signal mutation_selected(mutation: MutationData)
signal mutation_previewed(mutation: MutationData)

@export var mutation_pool: Array[MutationData] = []
@onready var cards: Array[MutationCard] = [
	%MutationCard1 as MutationCard,
	%MutationCard2 as MutationCard,
	%MutationCard3 as MutationCard,
]
var selection_locked: bool = false


func _ready() -> void:
	for card: MutationCard in cards:
		card.mutation_chosen.connect(_on_mutation_chosen)
		card.mutation_previewed.connect(_on_mutation_previewed)


func present_choices() -> void:
	selection_locked = false
	show()
	var choices: Array[MutationData] = mutation_pool.duplicate()
	choices.shuffle()
	for index: int in cards.size():
		cards[index].disabled = false
		cards[index].setup(choices[index])
	_on_mutation_previewed(choices[0])


func _on_mutation_chosen(mutation: MutationData) -> void:
	if selection_locked:
		return
	selection_locked = true
	for card: MutationCard in cards:
		card.disabled = true
	mutation_selected.emit(mutation)


func _on_mutation_previewed(mutation: MutationData) -> void:
	mutation_previewed.emit(mutation)
	%PreviewTitle.text = mutation.display_name
	%PreviewDescription.text = mutation.description
	%PreviewTexture.texture = mutation.visual_texture
	%PreviewTexture.modulate = Color.WHITE if mutation.visual_texture != null else _preview_color_for(mutation.effect_type)


func set_anatomy_summary(kaiju: Kaiju) -> void:
	var lines: PackedStringArray = []
	for component: KaijuComponent in kaiju.anatomy_controller.components:
		lines.append("%s  %d/%d  [%s]" % [
			component.data.display_name.to_upper(),
			int(component.current_health),
			int(component.data.max_health),
			"ONLINE" if not component.is_destroyed else "OFFLINE",
		])
	%AnatomyList.text = "\n".join(lines)


func _preview_color_for(effect_type: StringName) -> Color:
	match effect_type:
		&"bone_plating":
			return Color(0.72, 0.78, 0.95, 1.0)
		&"regeneration_tumor":
			return Color(0.52, 1.0, 0.55, 1.0)
	return Color.WHITE
