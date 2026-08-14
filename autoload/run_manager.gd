class_name RunManager
extends Node

const SAVE_SYSTEM: Script = preload("res://autoload/save_system.gd")
const MAP_CATALOG: Script = preload("res://battle/map_catalog.gd")

signal run_started
signal encounter_advanced(encounter_index: int)
signal run_finished(victory: bool)
signal battle_result_recorded(result: BattleResult)
signal salvage_claimed(choice: SalvageChoiceData)

enum RunPhase { COMBAT, MUTATION, COMPLETE, DEFEAT }

var encounter_index: int = 1
var phase: RunPhase = RunPhase.COMBAT
var selected_mutation_ids: Array[StringName] = []
var biomass_earned: int = 0
var specimen: SpecimenState = SpecimenState.new()
var latest_battle_result: BattleResult
var selected_map: BattleMapData = preload("res://data/battles/city_ruins.tres")
var save_path: String = "user://kaiju_lab_save.json"


func begin_run() -> void:
	encounter_index = 1
	phase = RunPhase.COMBAT
	selected_mutation_ids.clear()
	biomass_earned = 0
	run_started.emit()


func initialize_session() -> void:
	if continue_saved_specimen():
		encounter_index = 1
		phase = RunPhase.COMBAT
		return
	begin_run()


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
	specimen.total_deployments += 1
	if result.boss_defeated:
		var campaign_ids: Array[StringName] = []
		for map_data: BattleMapData in MAP_CATALOG.all_maps():
			campaign_ids.append(map_data.map_id)
		result.circuit_completed = specimen.record_map_victory(selected_map.map_id, campaign_ids)
		_refresh_map_unlocks()
	var choices: Array[SalvageChoiceData] = SalvageSystem.generate_choices(result, selected_map.map_id, specimen.threat_tier)
	specimen.set_pending_salvage(choices)
	SAVE_SYSTEM.save_specimen(specimen, save_path)
	battle_result_recorded.emit(result)


func claim_salvage(index: int) -> bool:
	if index < 0 or index >= specimen.pending_salvage_choices.size():
		return false
	var claimed: SalvageChoiceData = specimen.pending_salvage_choices[index]
	if not specimen.claim_salvage(index):
		return false
	SAVE_SYSTEM.save_specimen(specimen, save_path)
	salvage_claimed.emit(claimed)
	return true


func new_specimen() -> void:
	if FileAccess.file_exists(save_path):
		DirAccess.remove_absolute(save_path)
	specimen = SpecimenState.new()
	selected_map = MAP_CATALOG.by_id(&"city_ruins")
	latest_battle_result = null
	begin_run()


func continue_saved_specimen() -> bool:
	if not FileAccess.file_exists(save_path):
		return false
	specimen = SAVE_SYSTEM.load_specimen(save_path)
	return true


func select_map(map_data: BattleMapData) -> bool:
	if map_data == null or not map_data.is_unlocked_for(specimen) or map_data.battle_scene_path.is_empty() or not ResourceLoader.exists(map_data.battle_scene_path):
		return false
	selected_map = map_data
	return true


func _refresh_map_unlocks() -> void:
	for map_data: BattleMapData in MAP_CATALOG.all_maps():
		if map_data.is_unlocked_for(specimen) and map_data.map_id not in specimen.unlocked_map_ids:
			specimen.unlocked_map_ids.append(map_data.map_id)
