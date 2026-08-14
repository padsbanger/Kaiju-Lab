extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://battle/side_scroll_battle.tscn")


func _initialize() -> void:
	var battle: SideScrollBattle = BATTLE_SCENE.instantiate()
	root.add_child(battle)
	await process_frame
	battle.specimen.apply_damage(&"brain", 11.0, "result test")
	battle.director.defeated_count = 4
	var captured: Array[BattleResult] = []
	battle.battle_finished.connect(func(result: BattleResult) -> void: captured.append(result))
	battle._resolve(true)
	assert(captured.size() == 1)
	var result := captured[0]
	assert(result.victory and result.map_id == &"city_ruins")
	assert(result.enemies_defeated == 4)
	assert(result.component_damage.has("brain"))
	assert(result.component_damage["brain"]["cause"] == "result test")
	print("PASS: scene-independent battle result transfers rewards and anatomy damage")
	quit(0)

