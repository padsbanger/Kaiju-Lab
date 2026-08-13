extends SceneTree

const BATTLE_SCENE: PackedScene = preload("res://battle/side_scroll_battle.tscn")


func _initialize() -> void:
	var battle: SideScrollBattle = BATTLE_SCENE.instantiate() as SideScrollBattle
	root.add_child(battle)
	await process_frame
	var cues: Array[StringName] = []
	battle.audio_cues.cue_played.connect(func(cue: StringName) -> void: cues.append(cue))
	battle.audio_cues.play(&"wave_start")
	battle.audio_cues.play(&"boss_phase")
	assert(cues == [&"wave_start", &"boss_phase"])
	assert(battle.audio_cues.player.playing, "Audio cues must produce an audible retro tone")
	battle.cycle_speed()
	assert(Engine.time_scale == 2.0)
	battle.cycle_speed()
	assert(Engine.time_scale == 0.5)
	Engine.time_scale = 1.0
	assert(battle.get_node("UI/InspectButton") != null)
	assert(ResourceLoader.exists("res://art/pixel/vfx/explosion.png"))
	var before_vfx: int = battle.get_child_count()
	battle._spawn_vfx(load("res://art/pixel/vfx/explosion.png"), Vector2.ZERO)
	assert(battle.get_child_count() == before_vfx + 1, "Pixel VFX must be instantiated in battle")
	assert(battle.battle_director.map_data.target_duration_seconds == 150.0)
	assert(battle.battle_director.map_data.waves.size() == 4)
	assert(battle.kaiju.brain_controller.scan_interval >= 0.3)
	print("PASS: audio cue contract, speed/inspection controls, crisp VFX, and deployment budgets")
	quit(0)
