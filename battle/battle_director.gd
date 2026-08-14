class_name BattleDirector
extends Node

signal wave_spawned(wave_index: int)
signal boss_defeated

var map_data: BattleMapData
var kaiju: KaijuBattleActor
var next_wave_index: int = 0
var active_enemy_count: int = 0
var defeated_count: int = 0
var threat_level: int = 1


func configure(value: BattleMapData, actor: KaijuBattleActor, threat: int = 1) -> void:
	map_data = value
	kaiju = actor
	next_wave_index = 0
	active_enemy_count = 0
	defeated_count = 0
	threat_level = maxi(1, threat)


func update_progress(progress_x: float) -> void:
	if map_data == null:
		return
	while next_wave_index < map_data.waves.size() and progress_x >= map_data.waves[next_wave_index].trigger_x:
		spawn_wave(next_wave_index)
		next_wave_index += 1


func spawn_wave(index: int) -> Array[BattleEnemy]:
	var spawned: Array[BattleEnemy] = []
	if map_data == null or index < 0 or index >= map_data.waves.size():
		return spawned
	var wave := map_data.waves[index]
	for enemy_index: int in range(wave.count):
		var enemy := wave.enemy_scene.instantiate() as BattleEnemy
		if enemy == null:
			continue
		get_parent().add_child(enemy)
		var threat_multiplier := 1.0 + float(threat_level - 1) * 0.16
		enemy.max_health *= threat_multiplier
		enemy.health = enemy.max_health
		enemy.health_bar.max_value = enemy.max_health
		enemy.health_bar.value = enemy.health
		enemy.attack_damage *= 1.0 + float(threat_level - 1) * 0.1
		enemy.reward_value = roundi(enemy.reward_value * threat_multiplier)
		enemy.bind_target(kaiju)
		enemy.position = _entry_position(wave, enemy_index)
		enemy.defeated.connect(_on_enemy_defeated)
		active_enemy_count += 1
		spawned.append(enemy)
	wave_spawned.emit(index)
	return spawned


func _entry_position(wave: WaveData, enemy_index: int) -> Vector2:
	var x := wave.trigger_x + 360.0 + enemy_index * wave.spacing
	var y := map_data.ground_y
	match wave.entry_rule:
		"left":
			x = maxf(20.0, kaiju.position.x - 260.0 - enemy_index * wave.spacing)
		"air":
			y -= 95.0 + enemy_index * 12.0
		"fixed", "preplaced":
			x = wave.trigger_x + enemy_index * wave.spacing
	return Vector2(x, y)


func _on_enemy_defeated(_enemy: BattleEnemy, was_boss: bool) -> void:
	active_enemy_count = maxi(0, active_enemy_count - 1)
	defeated_count += 1
	if was_boss:
		boss_defeated.emit()
