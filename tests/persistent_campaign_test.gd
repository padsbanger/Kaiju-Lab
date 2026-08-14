extends SceneTree


func _initialize() -> void:
	var specimen := SpecimenState.new()
	specimen.initialize_default()
	specimen.apply_damage(&"arm_right", 23.0, "campaign test")
	var city_result := BattleResult.new()
	city_result.victory = true
	city_result.map_id = &"city_ruins"
	city_result.biomass_reward = 28
	city_result.dna_reward = 4
	city_result.experience_reward = 72
	specimen.record_battle_result(city_result)
	assert(specimen.unlocked_maps.has("toxic_swamp"))
	assert(specimen.total_deployments == 1 and specimen.total_victories == 1)

	var choices := SalvageSystem.generate_choices(city_result, specimen.circuit_level)
	assert(choices.size() == 3)
	specimen.set_pending_salvage(choices)
	var save_path := "user://kaiju_lab_campaign_test.json"
	assert(SaveSystem.save_specimen(specimen, save_path))
	var restored := SaveSystem.load_specimen(save_path)
	assert(restored.pending_salvage.size() == 3)
	assert(restored.components[&"arm_right"].damage_cause == "campaign test")
	var biomass_before := restored.biomass
	assert(restored.claim_salvage(&"biomass_recovery"))
	assert(restored.biomass > biomass_before)
	assert(not restored.claim_salvage(&"biomass_recovery"))

	var swamp_result := BattleResult.new()
	swamp_result.victory = true
	swamp_result.map_id = &"toxic_swamp"
	restored.record_battle_result(swamp_result)
	assert(restored.circuit_level == 2)
	assert(restored.circuit_progress.is_empty())
	DirAccess.remove_absolute(ProjectSettings.globalize_path(save_path))
	print("PASS: battle results, mandatory salvage, save round-trip, unlocks, and campaign circuit")
	quit(0)

