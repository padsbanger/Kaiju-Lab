class_name WaveData
extends Resource

enum SpawnRule { AHEAD_ENTRY, LEFT_ENTRY, FIXED_EMPLACEMENT, AIR_ENTRY, PREPLACED }

@export var wave_id: StringName
@export var title: String = "HOSTILE CONTACT"
@export_range(0.0, 1.0) var trigger_progress: float = 0.1
@export var spawn_rule: SpawnRule = SpawnRule.AHEAD_ENTRY
@export var enemy_scenes: Array[PackedScene] = []
@export var spacing: float = 1.6
@export var blocking: bool = true

