class_name BattleDirector
extends Node

signal phase_changed(phase: Phase, title: String)
signal wave_started(index: int, wave: WaveData)
signal wave_cleared(index: int)
signal preboss_sequence_complete

enum Phase { TRAVEL, WAVE, ELITE, BOSS, COMPLETE }

@export var map_data: BattleMapData
var battle: SideScrollBattle
var phase: Phase = Phase.TRAVEL
var next_wave_index: int = 0
var current_wave_index: int = -1
var living_enemies: Array[Node3D] = []
var enemies_defeated: int = 0
var waves_cleared: int = 0


func configure(owner_battle: SideScrollBattle) -> void:
	battle = owner_battle
	phase_changed.emit(phase, "ADVANCING")


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
		phase = Phase.BOSS
		preboss_sequence_complete.emit()


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
	var enemy: Node3D = scene.instantiate() as Node3D
	battle.enemy_root.add_child(enemy)
	var base_x: float = battle.kaiju.global_position.x + 5.0
	if wave.spawn_rule == WaveData.SpawnRule.LEFT_ENTRY:
		base_x = battle.kaiju.global_position.x - 4.0
	elif wave.spawn_rule in [WaveData.SpawnRule.FIXED_EMPLACEMENT, WaveData.SpawnRule.PREPLACED]:
		base_x = lerpf(2.0, battle.scroll_controller.boss_gate_x - 3.0, wave.trigger_progress)
	var height: float = 3.0 if wave.spawn_rule == WaveData.SpawnRule.AIR_ENTRY else 0.0
	enemy.global_position = Vector3(base_x + index * wave.spacing, height, 0.0)
	living_enemies.append(enemy)
	enemy.tree_exiting.connect(_on_enemy_removed.bind(enemy), CONNECT_ONE_SHOT)


func _on_enemy_removed(enemy: Node3D) -> void:
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

