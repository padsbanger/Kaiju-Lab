class_name SaveSystem
extends RefCounted

const SAVE_VERSION: int = 1
const DEFAULT_PATH: String = "user://kaiju_lab_save.json"


static func save_specimen(specimen: SpecimenState, path: String = DEFAULT_PATH) -> bool:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify({"version": SAVE_VERSION, "specimen": specimen.to_dictionary()}))
	return true


static func load_specimen(path: String = DEFAULT_PATH) -> SpecimenState:
	if not FileAccess.file_exists(path):
		return _fresh_specimen()
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return _fresh_specimen()
	var json := JSON.new()
	if json.parse(file.get_as_text()) != OK:
		return _fresh_specimen()
	var parsed: Variant = json.data
	if not parsed is Dictionary:
		return _fresh_specimen()
	var root_data := parsed as Dictionary
	if int(root_data.get("version", 0)) != SAVE_VERSION or not root_data.get("specimen", {}) is Dictionary:
		return _fresh_specimen()
	return SpecimenState.from_dictionary(root_data["specimen"])


static func _fresh_specimen() -> SpecimenState:
	var specimen := SpecimenState.new()
	specimen.initialize_default()
	return specimen
