extends SceneTree

const MAIN_SCENE: PackedScene = preload("res://main.tscn")


func _initialize() -> void:
	var main: Main = MAIN_SCENE.instantiate() as Main
	root.add_child(main)
	current_scene = main
	await process_frame
	await process_frame
	assert(main.lab_scene != null)
	var specimen: SpecimenState = main.run_manager.specimen
	assert(specimen.install_organ(&"claw_left", "res://data/components/claw_tendril.tres"))
	main.deploy()
	await process_frame
	await process_frame
	var battle: SideScrollBattle = main.combat_scene
	assert(battle != null and battle.kaiju.claw_attack.cooldown == 0.48)
	var director: BattleDirector = battle.battle_director
	director.set_process(false)
	for index: int in director.map_data.waves.size():
		director.start_wave(index)
		await process_frame
		for enemy: Node3D in director.living_enemies.duplicate():
			enemy.take_damage(9999.0, battle.kaiju)
		await process_frame
		await process_frame
	director._begin_boss()
	await process_frame
	var component_id: StringName = battle.kaiju.anatomy_controller.components[0].data.id
	battle.kaiju.anatomy_controller.components[0].take_damage(25.0, battle.boss)
	battle.boss.take_damage(9999.0, battle.kaiju)
	await create_timer(0.6).timeout
	assert(main.lab_scene != null and main.combat_scene == null)
	assert(main.run_manager.latest_battle_result.boss_defeated)
	assert(specimen.experience >= specimen.experience_to_next_level)
	var damaged: ComponentState = specimen.component_states[component_id]
	assert(damaged.current_health < damaged.max_health)
	assert(main.lab_scene.regeneration.repair(specimen, damaged.component_id))
	assert(specimen.level_up())
	assert(specimen.install_organ(&"claw_left", "res://data/components/claw_hammer.tres"))
	main.deploy()
	await process_frame
	await process_frame
	assert(main.combat_scene.kaiju.claw_attack.damage == 39.0)
	assert(main.scene_root.get_child_count() == 1, "Transitions must never duplicate active scenes")
	print("PASS: lab -> waves -> boss -> damaged lab -> repair/level/change -> redeploy")
	quit(0)
