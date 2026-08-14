extends SceneTree


func _initialize() -> void:
	var result := BattleResult.new()
	result.map_progress = 0.75
	result.enemies_defeated = 9
	result.waves_survived = 3
	var choices: Array[SalvageChoiceData] = SalvageSystem.generate_choices(result, &"city_ruins", 1)
	assert(choices.size() == 3)
	assert(choices[0].biomass_reward > 0 and choices[1].dna_reward > 0 and choices[2].experience_reward > 0)
	var specimen := SpecimenState.new()
	var initial_dna: int = specimen.dna
	specimen.set_pending_salvage(choices)
	assert(specimen.has_pending_salvage())
	assert(specimen.claim_salvage(1))
	assert(specimen.dna == initial_dna + choices[1].dna_reward)
	assert(not specimen.claim_salvage(1), "Salvage must only be claimed once")
	assert(not specimen.has_pending_salvage())
	var lab_scene: PackedScene = load("res://lab/lab_scene.tscn") as PackedScene
	var lab: LabController = lab_scene.instantiate() as LabController
	root.add_child(lab)
	await process_frame
	specimen.set_pending_salvage(choices)
	lab.bind_specimen(specimen, result)
	var emitted_indices: Array[int] = []
	lab.salvage_requested.connect(func(index: int) -> void: emitted_indices.append(index))
	lab.salvage_buttons[1].pressed.emit()
	assert(emitted_indices == [1], "Each salvage button must retain its own choice index")
	print("PASS: deployment generates three strategic salvage choices and exactly one can be claimed")
	quit(0)
