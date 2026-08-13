class_name Main
extends Node

signal prototype_event(message: String)

@onready var status_label: Label = %StatusLabel
@onready var health_bar: ProgressBar = %HealthBar
@onready var combat_scene: CombatScene = $CombatScene
@onready var mutation_selection: MutationSelection = %MutationSelection
@onready var mutation_system: MutationSystem = $MutationSystem


func _ready() -> void:
	combat_scene.status_changed.connect(report_event)
	combat_scene.kaiju_health_changed.connect(_on_kaiju_health_changed)
	combat_scene.combat_finished.connect(_on_combat_finished)
	mutation_selection.mutation_selected.connect(_on_mutation_selected)
	report_event("SPECIMEN K-01 // ARENA LINK STABLE")


func report_event(message: String) -> void:
	status_label.text = message
	prototype_event.emit(message)
	print("[KaijuLab] ", message)


func _on_kaiju_health_changed(current: float, maximum: float) -> void:
	health_bar.max_value = maximum
	health_bar.value = current


func _on_combat_finished(result: StringName) -> void:
	if result == &"victory":
		get_tree().paused = true
		mutation_selection.present_choices()


func _on_mutation_selected(mutation: MutationData) -> void:
	if mutation_system.apply_mutation(combat_scene.kaiju, mutation):
		report_event("MUTATION APPLIED // %s" % mutation.display_name)
	mutation_selection.hide()
	get_tree().paused = false
