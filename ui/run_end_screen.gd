class_name RunEndScreen
extends Control

signal restart_requested

@onready var title: Label = %Title
@onready var summary: Label = %Summary


func present(victory: bool, encounter_index: int, mutation_ids: Array[StringName]) -> void:
	show()
	title.text = "PROTOTYPE COMPLETE" if victory else "SPECIMEN LOST"
	var mutation_text: String = ", ".join(mutation_ids) if not mutation_ids.is_empty() else "NONE"
	summary.text = "ENCOUNTERS RESOLVED: %d\nMUTATIONS: %s\n\nThe organism will be reset for the next experiment." % [encounter_index if victory else encounter_index - 1, mutation_text]


func _on_restart_pressed() -> void:
	restart_requested.emit()
