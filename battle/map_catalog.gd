class_name MapCatalog
extends RefCounted

const MAP_PATHS: Array[String] = [
	"res://data/battles/city_ruins.tres",
	"res://data/battles/toxic_swamp.tres",
]


static func all_maps() -> Array[BattleMapData]:
	var maps: Array[BattleMapData] = []
	for path: String in MAP_PATHS:
		var map_data: BattleMapData = load(path) as BattleMapData
		if map_data != null:
			maps.append(map_data)
	return maps


static func by_id(map_id: StringName) -> BattleMapData:
	for map_data: BattleMapData in all_maps():
		if map_data.map_id == map_id:
			return map_data
	return null
