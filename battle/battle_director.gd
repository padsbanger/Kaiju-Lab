class_name BattleDirector
extends Node

signal phase_changed(phase: Phase, title: String)
signal wave_started(index: int, wave: WaveData)
signal wave_cleared(index: int)
signal preboss_sequence_complete
signal boss_spawned(boss: Node2D)

enum Phase { TRAVEL, WAVE, ELITE, BOSS, COMPLETE }

@export var map_data: BattleMapData
var battle: SideScrollBattle
var phase: Phase = Phase.TRAVEL
var next_wave_index: int = 0
var current_wave_index: int = -1
var living_enemies: Array[Node2D] = []
var enemies_defeated: int = 0
var waves_cleared: int = 0
var boss_scene: PackedScene = preload("res://enemies/citadel_boss.tscn")
var boss: Node2D


func configure(owner_battle: SideScrollBattle) -> void:
	battle = owner_battle
	phase_changed.emit(phase, "ADVANCING")
	# A deployment should show a hostile immediately; otherwise the long initial
	# march reads as an empty scene rather than an autobattle.
	call_deferred("start_wave", 0)


func _process(_delta: float) -> void:
	if battle == null or map_data == null or phase == Phase.BOSS or phase == Phase.COMPLETE:
		return
	_prune_enemies()
	if phase in [Phase.WAVE, Phase.ELITE] and living_enemies.is_empty():
		waves_cleared += 1
		wave_cleared.emit(current_wave_index)
		phase = Phase.TRAVEL
		phase_changed.emit(phase, "SECTOR CLEAR")
	if phase == Phase.TRAVEL and next_wave_index < map_data.waves.size():
		var wave: WaveData = map_data.waves[next_wave_index]
		if battle.scroll_controller.progress >= wave.trigger_progress:
			start_wave(next_wave_index)
	elif phase == Phase.TRAVEL and next_wave_index >= map_data.waves.size():
		_begin_boss()


func start_wave(index: int) -> void:
	if map_data == null or index < 0 or index >= map_data.waves.size() or index < next_wave_index:
		return
	var wave: WaveData = map_data.waves[index]
	current_wave_index = index
	next_wave_index = index + 1
	phase = Phase.ELITE if index == map_data.waves.size() - 1 else Phase.WAVE
	for enemy_index: int in wave.enemy_scenes.size():
		_spawn_enemy(wave.enemy_scenes[enemy_index], wave, enemy_index)
	wave_started.emit(index, wave)
	phase_changed.emit(phase, wave.title)


func _spawn_enemy(scene: PackedScene, wave: WaveData, index: int) -> void:
	if scene == null:
		return
	var enemy: Node2D = scene.instantiate() as Node2D
	battle.enemy_root.add_child(enemy)
	# Standard waves enter from just beyond the right camera edge, then march
	# into view. This avoids sudden enemies materialising beside the kaiju.
	var base_x: float = battle.right_screen_x() + 80.0
	if wave.spawn_rule == WaveData.SpawnRule.LEFT_ENTRY:
		base_x = battle.kaiju.global_position.x - 180.0
	elif wave.spawn_rule in [WaveData.SpawnRule.FIXED_EMPLACEMENT, WaveData.SpawnRule.PREPLACED]:
		base_x = lerpf(320.0, battle.scroll_controller.boss_gate_x - 240.0, wave.trigger_progress)
	var spawn_y: float = battle.ground_y - 135.0 if wave.spawn_rule == WaveData.SpawnRule.AIR_ENTRY else battle.ground_y
	var spacing: float = maxf(90.0, wave.spacing * 40.0)
	enemy.global_position = Vector2(base_x + index * spacing, spawn_y)
	living_enemies.append(enemy)
	enemy.tree_exiting.connect(_on_enemy_removed.bind(enemy), CONNECT_ONE_SHOT)


func _on_enemy_removed(enemy: Node2D) -> void:
	if enemy in living_enemies:
		living_enemies.erase(enemy)
		enemies_defeated += 1


func _prune_enemies() -> void:
	for index: int in range(living_enemies.size() - 1, -1, -1):
		if not is_instance_valid(living_enemies[index]) or not living_enemies[index].is_inside_tree():
			living_enemies.remove_at(index)


func remaining_count() -> int:
	_prune_enemies()
	return living_enemies.size()


func phase_name() -> String:
	return Phase.keys()[phase]


func _begin_boss() -> void:
	if phase == Phase.BOSS or boss != null:
		return
	phase = Phase.BOSS
	preboss_sequence_complete.emit()
	boss = boss_scene.instantiate() as Node2D
	battle.enemy_root.add_child(boss)
	boss.global_position = Vector2(battle.scroll_controller.boss_gate_x + 160.0, battle.ground_y)
	living_enemies.append(boss)
	boss.tree_exiting.connect(_on_enemy_removed.bind(boss), CONNECT_ONE_SHOT)
	boss.died.connect(func(_enemy: Node2D) -> void: phase = Phase.COMPLETE)
	boss_spawned.emit(boss)
	phase_changed.emit(phase, "FINAL BOSS // THE CITADEL")
