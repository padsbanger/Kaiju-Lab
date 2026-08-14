class_name BattleMapData
extends Resource

@export var map_id: StringName
@export var display_name: String = "Unknown Biome"
@export var length: float = 3600.0
@export var ground_y: float = 290.0
@export var sky_color: Color = Color(0.05, 0.08, 0.12)
@export var accent_color: Color = Color(0.3, 0.8, 0.5)
@export var waves: Array[WaveData] = []

