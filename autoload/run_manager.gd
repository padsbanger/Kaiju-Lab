class_name RunManager
extends Node

signal run_started
signal encounter_advanced(encounter_index: int)
signal run_finished(victory: bool)
signal battle_result_recorded(result: BattleResult)

enum RunPhase { COMBAT, MUTATION, COMPLETE, DEFEAT }

var encounter_index: int = 1
var phase: RunPhase = RunPhase.COMBAT
var selected_mutation_ids: Array[StringName] = []
var biomass_earned: int = 0
var specimen: SpecimenState = SpecimenState.new()
var latest_battle_result: BattleResult


func begin_run() -> void:
	encounter_index = 1
	phase = RunPhase.COMBAT
	selected_mutation_ids.clear()
	biomass_earned = 0
	run_started.emit()


func begin_mutation_phase() -> void:
	phase = RunPhase.MUTATION


func record_mutation(mutation: MutationData) -> void:
	if mutation.id not in selected_mutation_ids:
		selected_mutation_ids.append(mutation.id)


func advance_encounter() -> void:
	encounter_index += 1
	phase = RunPhase.COMBAT
	encounter_advanced.emit(encounter_index)


func finish_run(victory: bool) -> void:
	phase = RunPhase.COMPLETE if victory else RunPhase.DEFEAT
	run_finished.emit(victory)


func register_specimen(kaiju: Kaiju) -> void:
	specimen.initialize_from_kaiju(kaiju)


func record_battle_result(result: BattleResult) -> void:
	latest_battle_result = result
	result.apply_to_specimen(specimen)
	battle_result_recorded.emit(result)


func new_specimen() -> void:
	specimen = SpecimenState.new()
	latest_battle_result = null
	begin_run()
