extends SceneTree


func _initialize() -> void:
	var backdrop := load("res://art/lab/lab_backdrop.png") as Texture2D
	assert(backdrop != null and backdrop.get_width() > 640 and backdrop.get_height() > 360)
	assert(ComponentCatalog.ALL.size() >= 12)
	assert(MutationCatalog.ALL.size() >= 3)
	for socket: StringName in [&"brain", &"heart", &"stomach", &"torso", &"arm_left", &"arm_right"]:
		assert(ComponentCatalog.compatible_with(socket).size() >= 2)
	assert(MapCatalog.ALL.size() == 2)
	assert(MapCatalog.CITY_RUINS.layer_colors != MapCatalog.TOXIC_SWAMP.layer_colors)

	var specimen := SpecimenState.new()
	specimen.initialize_default()
	specimen.dna = 10
	var base_damage := specimen.damage_multiplier()
	assert(specimen.apply_mutation(MutationCatalog.BONE_PLATING))
	assert(specimen.damage_multiplier() < base_damage)
	specimen.apply_damage(&"arm_left", 20.0, "content test")
	specimen.apply_mutation(MutationCatalog.REGENERATION_TUMOR)
	specimen.energy = 80.0
	specimen.heat = 75.0
	var health_before := specimen.components[&"arm_left"].health
	assert(specimen.regenerate_tick(2.0) > 0.0)
	assert(specimen.components[&"arm_left"].health > health_before)
	print("PASS: original art, organ alternatives, biome palettes, and mechanical mutations")
	quit(0)

