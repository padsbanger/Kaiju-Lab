class_name SaveSystem
extends RefCounted

const SAVE_VERSION: int = 2


static func save_specimen(specimen: SpecimenState, path: String = "user://kaiju_lab_save.json") -> Error:
	if specimen == null:
		return ERR_INVALID_PARAMETER
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(JSON.stringify({"version": SAVE_VERSION, "specimen": specimen.to_save_data()}))
	return OK


static func load_specimen(path: String = "user://kaiju_lab_save.json") -> SpecimenState:
	if not FileAccess.file_exists(path):
		return SpecimenState.new()
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return SpecimenState.new()
	var parser := JSON.new()
	if parser.parse(file.get_as_text()) != OK:
		return SpecimenState.new()
	var parsed: Variant = parser.data
	if not parsed is Dictionary:
		return SpecimenState.new()
	var payload: Dictionary = parsed as Dictionary
	var version: int = int(payload.get("version", 0))
	if version < 1 or version > SAVE_VERSION or not payload.get("specimen", {}) is Dictionary:
		return SpecimenState.new()
	return SpecimenState.from_save_data(payload["specimen"] as Dictionary)
