extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://battle/side_scroll_battle.tscn")
const SOLDIER_SCENE: PackedScene = preload("res://enemies/melee_soldier.tscn")


func _initialize() -> void:
	var battle: SideScrollBattle = BATTLE_SCENE.instantiate() as SideScrollBattle
	root.add_child(battle)
	await process_frame
	await create_timer(0.8).timeout
	assert(battle.battle_controller.state == KaijuBattleController.State.ADVANCE)
	assert(battle.kaiju.velocity.x > 0.2, "Advance must accelerate heavily rather than teleport")
	var soldier: MeleeSoldier = SOLDIER_SCENE.instantiate() as MeleeSoldier
	battle.add_child(soldier)
	soldier.global_position = battle.kaiju.global_position + Vector3(2.8, 0.0, 0.0)
	battle.kaiju.brain_controller.select_target()
	await create_timer(0.35).timeout
	assert(battle.battle_controller.state == KaijuBattleController.State.ENGAGE)
	assert(battle.kaiju.velocity.x < 0.7, "Kaiju must decelerate for a blocking threat")
	soldier.queue_free()
	await create_timer(0.8).timeout
	assert(battle.battle_controller.state == KaijuBattleController.State.ADVANCE)
	assert(battle.kaiju.velocity.x > 0.2, "Advance must resume after the threat clears")
	assert(battle.kaiju.brain_controller.scan_interval >= 0.3, "Target evaluation must remain staggered")
	print("PASS: heavy ADVANCE -> ENGAGE -> ADVANCE autonomous state flow")
	quit(0)
