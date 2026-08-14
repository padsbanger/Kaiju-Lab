class_name WaveData
extends Resource

@export var wave_id: StringName
@export var trigger_x: float = 600.0
@export var enemy_scene: PackedScene
@export var count: int = 1
@export var spacing: float = 70.0
@export_enum("ahead", "left", "air", "fixed", "preplaced") var entry_rule: String = "ahead"
@export var is_boss_wave: bool = false

