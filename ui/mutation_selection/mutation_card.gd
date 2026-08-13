class_name MutationCard
extends Button

signal mutation_chosen(mutation: MutationData)
signal mutation_previewed(mutation: MutationData)

var mutation: MutationData


func setup(data: MutationData) -> void:
	mutation = data
	text = "%s\n\n%s\n\n%s" % [data.display_name, data.description, data.rarity]
	if not pressed.is_connected(_on_pressed):
		pressed.connect(_on_pressed)
	if not mouse_entered.is_connected(_on_mouse_entered):
		mouse_entered.connect(_on_mouse_entered)


func _on_pressed() -> void:
	mutation_chosen.emit(mutation)


func _on_mouse_entered() -> void:
	if mutation != null:
		mutation_previewed.emit(mutation)
