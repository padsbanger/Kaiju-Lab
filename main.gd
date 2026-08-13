class_name Main
extends Node

signal prototype_event(message: String)

@onready var status_label: Label = %StatusLabel
@onready var health_bar: ProgressBar = %HealthBar
@onready var combat_scene: CombatScene = $CombatScene
@onready var mutation_selection: MutationSelection = %MutationSelection
@onready var mutation_system: MutationSystem = $MutationSystem
@onready var run_manager: RunManager = $RunManager
@onready var run_end_screen: RunEndScreen = %RunEndScreen
@onready var combat_telemetry: CombatTelemetry = %CombatTelemetry
@onready var combat_feedback: CombatFeedback = $CombatFeedback


func _ready() -> void:
	combat_scene.status_changed.connect(report_event)
	combat_scene.kaiju_health_changed.connect(_on_kaiju_health_changed)
	combat_scene.combat_finished.connect(_on_combat_finished)
	mutation_selection.mutation_selected.connect(_on_mutation_selected)
	run_end_screen.restart_requested.connect(_on_restart_requested)
	run_manager.begin_run()
	combat_telemetry.bind(combat_scene.kaiju)
	combat_feedback.bind(combat_scene.kaiju)
	report_event("SPECIMEN K-01 // ARENA LINK STABLE")


func report_event(message: String) -> void:
	status_label.text = message
	prototype_event.emit(message)
	print("[KaijuLab] ", message)


func _on_kaiju_health_changed(current: float, maximum: float) -> void:
	health_bar.max_value = maximum
	health_bar.value = current


func _on_combat_finished(result: StringName) -> void:
	if result == &"victory" and run_manager.encounter_index == 1:
		run_manager.begin_mutation_phase()
		get_tree().paused = true
		mutation_selection.set_anatomy_summary(combat_scene.kaiju)
		mutation_selection.present_choices()
	elif result == &"victory":
		run_manager.finish_run(true)
		get_tree().paused = true
		run_end_screen.present(true, run_manager.encounter_index, run_manager.selected_mutation_ids)
	else:
		run_manager.finish_run(false)
		get_tree().paused = true
		run_end_screen.present(false, run_manager.encounter_index, run_manager.selected_mutation_ids)


func _on_mutation_selected(mutation: MutationData) -> void:
	if mutation_system.apply_mutation(combat_scene.kaiju, mutation):
		run_manager.record_mutation(mutation)
		report_event("MUTATION APPLIED // %s" % mutation.display_name)
	mutation_selection.hide()
	get_tree().paused = false
	run_manager.advance_encounter()
	combat_scene.start_encounter(run_manager.encounter_index)


func _on_restart_requested() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
