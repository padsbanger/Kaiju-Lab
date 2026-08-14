class_name MapCatalog
extends RefCounted

const CITY_RUINS: BattleMapData = preload("res://data/battles/city_ruins.tres")
const TOXIC_SWAMP: BattleMapData = preload("res://data/battles/toxic_swamp.tres")
const ALL: Array[BattleMapData] = [CITY_RUINS, TOXIC_SWAMP]


static func get_by_id(map_id: StringName) -> BattleMapData:
	for map: BattleMapData in ALL:
		if map.map_id == map_id:
			return map
	return CITY_RUINS


static func available_for(specimen: SpecimenState) -> Array[BattleMapData]:
	var result: Array[BattleMapData] = []
	for map: BattleMapData in ALL:
		if specimen.unlocked_maps.has(String(map.map_id)):
			result.append(map)
	return result

