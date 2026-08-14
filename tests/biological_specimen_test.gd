extends SceneTree


func _initialize() -> void:
	var specimen := SpecimenState.new()
	specimen.initialize_default()
	assert(specimen.components.size() == 6)
	assert(specimen.has_function(&"structure"))
	assert(specimen.has_function(&"circulation"))
	assert(specimen.has_function(&"digestion"))
	assert(specimen.has_function(&"cognition"))

	var energy_before := specimen.energy
	assert(specimen.try_activate(&"arm_left"))
	assert(specimen.energy < energy_before)
	assert(specimen.heat > 0.0)

	specimen.apply_damage(&"heart", 999.0, "anti-organ shell")
	specimen.simulate(10.0)
	assert(not specimen.has_function(&"circulation"))
	assert(not specimen.has_function(&"cognition"))
	assert(specimen.movement_multiplier() < 0.2)
	assert(not specimen.try_activate(&"arm_right"))
	assert(not specimen.components[&"arm_right"].offline_reason.is_empty())

	var repair_cost := specimen.repair_cost(&"heart")
	var biomass_before := specimen.biomass
	assert(repair_cost > 0 and specimen.repair(&"heart"))
	assert(specimen.biomass == biomass_before - repair_cost)
	assert(specimen.components[&"heart"].health == specimen.components[&"heart"].definition.max_health)

	specimen.apply_damage(&"arm_left", 17.0, "rifle fire")
	var restored := SpecimenState.from_dictionary(specimen.to_dictionary())
	assert(restored.components[&"arm_left"].health == specimen.components[&"arm_left"].health)
	assert(restored.components[&"arm_left"].damage_cause == "rifle fire")
	assert(restored.components[&"arm_left"].definition.component_id == &"claw_left")
	print("PASS: biological dependencies, resources, damage, repair, and serialization")
	quit(0)

