class_name MutationSelection
extends Control

signal mutation_selected(mutation: MutationData)

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


func present_choices() -> void:
	selection_locked = false
	show()
	var choices: Array[MutationData] = mutation_pool.duplicate()
	choices.shuffle()
	for index: int in cards.size():
		cards[index].disabled = false
		cards[index].setup(choices[index])


func _on_mutation_chosen(mutation: MutationData) -> void:
	if selection_locked:
		return
	selection_locked = true
	for card: MutationCard in cards:
		card.disabled = true
	mutation_selected.emit(mutation)
