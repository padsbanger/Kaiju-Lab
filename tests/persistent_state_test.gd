extends SceneTree

const KAIJU_SCENE: PackedScene = preload("res://kaiju/kaiju.tscn")


func _initialize() -> void:
	var kaiju: Kaiju = KAIJU_SCENE.instantiate() as Kaiju
	root.add_child(kaiju)
	await process_frame
	var specimen := SpecimenState.new()
	specimen.initialize_from_kaiju(kaiju)
	var claw: KaijuComponent = kaiju.anatomy_controller.get_component(&"claw_left")
	claw.take_damage(20.0)
	var result := BattleResult.new()
	result.outcome = BattleResult.Outcome.BOSS_DEFEATED
	result.experience_reward = 120
	result.biomass_reward = 35
	result.capture_components(kaiju)
	result.damage_causes[&"claw_left"] = "Tank shell fractured the pincer"
	result.apply_to_specimen(specimen)
	var saved_health: float = (specimen.component_states[&"claw_left"] as ComponentState).current_health
	kaiju.queue_free()
	await process_frame
	assert(saved_health > 0.0 and saved_health < 58.0)
	assert(specimen.experience == 120 and specimen.biomass == 285)
	assert((specimen.component_states[&"claw_left"] as ComponentState).last_damage_cause.contains("Tank"))
	print("PASS: persistent specimen and battle result survive freed battle nodes")
	quit(0)
