extends SceneTree

const LAB_SCENE: PackedScene = preload("res://lab/lab_scene.tscn")


func _initialize() -> void:
	var lab: LabController = LAB_SCENE.instantiate() as LabController
	root.add_child(lab)
	await process_frame
	var specimen := SpecimenState.new()
	specimen.initialize_from_kaiju(lab.kaiju)
	var torso_id: StringName = &"torso_basic"
	var torso: ComponentState = specimen.component_states[torso_id]
	torso.current_health = 0.0
	torso.last_damage_cause = "Citadel siege cannon"
	var result := BattleResult.new()
	result.component_health[torso_id] = 0.0
	result.enemies_defeated = 7
	lab.bind_specimen(specimen, result)
	assert(lab.kaiju.anatomy_controller.components[0].is_destroyed)
	assert(lab.deploy_button.disabled, "Critical destruction must block deployment")
	assert("BATTLE REPORT" in lab.report_label.text and "TORSO_BASIC" in lab.report_label.text)
	var before: int = specimen.biomass
	assert(lab.regeneration.repair(specimen, torso_id))
	assert(specimen.biomass < before and torso.current_health == torso.max_health)
	specimen.apply_to_kaiju(lab.kaiju)
	assert(not lab.kaiju.anatomy_controller.components[0].is_destroyed)
	assert(lab.regeneration.can_deploy(specimen))
	print("PASS: persistent wounds, damage report, paid regeneration, and readiness")
	quit(0)
