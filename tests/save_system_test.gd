extends SceneTree

const SAVE_SYSTEM: Script = preload("res://autoload/save_system.gd")
const KAIJU_SCENE: PackedScene = preload("res://kaiju/kaiju.tscn")


func _initialize() -> void:
	var specimen := SpecimenState.new()
	specimen.level = 4
	specimen.experience = 177
	specimen.biomass = 321
	specimen.dna = 88
	specimen.mutation_ids = [&"acid_gland", &"bone_plating"]
	specimen.unlocked_map_ids = [&"city_ruins", &"toxic_swamp"]
	specimen.total_deployments = 7
	specimen.total_victories = 4
	specimen.circuit_level = 3
	specimen.threat_tier = 3
	specimen.map_victories = {&"city_ruins": 3, &"toxic_swamp": 1}
	specimen.circuit_cleared_map_ids = [&"city_ruins"]
	var pending_result := BattleResult.new()
	pending_result.map_progress = 0.6
	pending_result.enemies_defeated = 5
	pending_result.waves_survived = 2
	specimen.set_pending_salvage(SalvageSystem.generate_choices(pending_result, &"city_ruins", specimen.threat_tier))
	var state := ComponentState.new()
	state.component_id = &"claw_left"
	state.max_health = 46.0
	state.current_health = 19.0
	state.installed_resource_path = "res://data/components/claw_tendril.tres"
	state.last_damage_cause = "Enemy attack: Tank"
	specimen.component_states[state.component_id] = state
	var save_path: String = "user://kaiju_lab_test_save.json"
	assert(SAVE_SYSTEM.save_specimen(specimen, save_path) == OK)
	var loaded: SpecimenState = SAVE_SYSTEM.load_specimen(save_path)
	assert(loaded.level == 4 and loaded.experience == 177 and loaded.biomass == 321 and loaded.dna == 88)
	assert(loaded.mutation_ids == [&"acid_gland", &"bone_plating"])
	assert(&"toxic_swamp" in loaded.unlocked_map_ids)
	assert(loaded.total_deployments == 7 and loaded.total_victories == 4 and loaded.circuit_level == 3 and loaded.threat_tier == 3)
	assert(loaded.map_clear_count(&"city_ruins") == 3 and &"city_ruins" in loaded.circuit_cleared_map_ids)
	assert(loaded.has_pending_salvage() and loaded.pending_salvage_choices.size() == 3)
	assert(loaded.claim_salvage(2) and not loaded.has_pending_salvage())
	var loaded_claw: ComponentState = loaded.component_states[&"claw_left"] as ComponentState
	assert(loaded_claw.current_health == 19.0 and loaded_claw.installed_resource_path.ends_with("claw_tendril.tres"))
	var kaiju: Kaiju = KAIJU_SCENE.instantiate() as Kaiju
	root.add_child(kaiju)
	await process_frame
	loaded.apply_to_kaiju(kaiju)
	assert(kaiju.damage_resistance > 0.0 and kaiju.spit_attack.damage > 16.0, "Saved mutation effects must reapply to loaded specimens")
	var resistance_after_first_apply: float = kaiju.damage_resistance
	var ranged_damage_after_first_apply: float = kaiju.spit_attack.damage
	loaded.apply_to_kaiju(kaiju)
	assert(is_equal_approx(kaiju.damage_resistance, resistance_after_first_apply), "Repeated loadout refresh must not stack resistance mutations")
	assert(is_equal_approx(kaiju.spit_attack.damage, ranged_damage_after_first_apply), "Repeated loadout refresh must not stack attack mutations")
	var corrupt := FileAccess.open(save_path, FileAccess.WRITE)
	corrupt.store_string("not-json")
	corrupt = null
	var fallback: SpecimenState = SAVE_SYSTEM.load_specimen(save_path)
	assert(fallback.level == 1 and fallback.component_states.is_empty(), "Corrupt saves must recover to safe defaults")
	DirAccess.remove_absolute(save_path)
	print("PASS: versioned specimen save/load round trip and corrupt-save recovery")
	quit(0)
