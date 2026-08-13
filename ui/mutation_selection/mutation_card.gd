class_name MutationCard
extends Button

signal mutation_chosen(mutation: MutationData)

var mutation: MutationData


func setup(data: MutationData) -> void:
	mutation = data
	text = "%s\n\n%s\n\n%s" % [data.display_name, data.description, data.rarity]
	pressed.connect(_on_pressed)


func _on_pressed() -> void:
	mutation_chosen.emit(mutation)
