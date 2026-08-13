extends SceneTree

const COMBAT_SCENE: PackedScene = preload("res://encounters/combat_scene.tscn")


func _initialize() -> void:
	var combat: CombatScene = COMBAT_SCENE.instantiate() as CombatScene
	root.add_child(combat)
	await process_frame
	assert(combat.kaiju.brain_controller.scan_interval >= 0.1, "Brain scoring must not run every frame")
	assert(combat.kaiju.brain_controller.scan_interval <= 0.5, "Brain scoring must remain responsive")
	assert(combat.encounter_manager.active_enemies.size() <= 8, "Prototype encounter exceeds authored entity budget")
	for enemy: Node in get_nodes_in_group(&"enemies"):
		if enemy.has_node("RangedAttack"):
			var ranged: RangedAttack = enemy.get_node("RangedAttack") as RangedAttack
			assert(ranged.cooldown >= 1.0, "Ranged units exceed projectile spawn budget")
	print("PASS: AI cadence, encounter count, and projectile-rate budgets")
	quit(0)
