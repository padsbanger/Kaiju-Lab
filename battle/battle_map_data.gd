class_name BattleMapData
extends Resource

@export var map_id: StringName = &"city_ruins"
@export var display_name: String = "CITY RUINS"
@export var unlock_after_map_id: StringName
@export var unlock_after_victories: int = 0
@export var target_duration_seconds: float = 150.0
@export_file("*.tscn") var battle_scene_path: String = "res://battle/side_scroll_battle.tscn"
@export_file("*.tscn") var parallax_scene_path: String = "res://levels/city_ruins/city_ruins_parallax.tscn"
@export_file("*.tscn") var boss_scene_path: String = "res://enemies/citadel_boss.tscn"
@export_file("*.tscn") var hazard_scene_path: String = ""
@export var waves: Array[WaveData] = []


func is_unlocked_for(specimen: SpecimenState) -> bool:
	if specimen == null:
		return false
	if unlock_after_map_id.is_empty() or unlock_after_victories <= 0:
		return true
	return specimen.map_victories.get(unlock_after_map_id, 0) >= unlock_after_victories
