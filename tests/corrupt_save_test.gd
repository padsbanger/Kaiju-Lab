extends SceneTree


func _initialize() -> void:
	var save_path := "user://kaiju_lab_corrupt_test.json"
	var file := FileAccess.open(save_path, FileAccess.WRITE)
	assert(file != null)
	file.store_string("{ definitely not valid json")
	file.close()
	var recovered := SaveSystem.load_specimen(save_path)
	assert(recovered.components.size() == 6)
	assert(recovered.unlocked_maps.has("city_ruins"))
	assert(recovered.circuit_level == 1)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(save_path))
	print("PASS: corrupt saves recover to validated fresh specimen defaults")
	quit(0)

