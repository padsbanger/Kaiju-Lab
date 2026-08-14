extends SceneTree

const KAIJU_SCENE: PackedScene = preload("res://kaiju/kaiju.tscn")


func _initialize() -> void:
	var kaiju: Kaiju = KAIJU_SCENE.instantiate() as Kaiju
	root.add_child(kaiju)
	await process_frame
	var specimen := SpecimenState.new()
	specimen.initialize_from_kaiju(kaiju)
	assert(specimen.compatible_organs(&"brain_predator").size() >= 3)
	assert(specimen.compatible_organs(&"heart_basic").size() >= 3)
	assert(specimen.compatible_organs(&"stomach_basic").size() >= 3)
	assert(specimen.compatible_organs(&"torso_basic").size() >= 3)
	var initial_biomass: int = specimen.biomass
	assert(specimen.install_organ(&"heart_basic", "res://data/components/heart_hypercardiac.tres"))
	assert(specimen.install_organ(&"stomach_basic", "res://data/components/stomach_furnace.tres"))
	assert(specimen.install_organ(&"torso_basic", "res://data/components/torso_hollow.tres"))
	assert(specimen.biomass < initial_biomass, "Organ installation must spend explicit biomass")
	specimen.apply_to_kaiju(kaiju)
	assert(kaiju.anatomy_controller.function_efficiency(&"circulation") > 1.0)
	assert(kaiju.loadout_movement_multiplier > 1.0)
	assert(kaiju.resource_controller.anatomy.total_online_property(&"energy_generation") >= 13.0)
	assert(specimen.build_analysis().contains("METABOLIC OVERDRIVE"))
	assert(not specimen.install_organ(&"heart_basic", "res://data/components/torso_fortress.tres"), "Resource ids must match the physical socket")
	print("PASS: multi-socket organs spend biomass and create distinct circulation, metabolism, and frame builds")
	quit(0)
