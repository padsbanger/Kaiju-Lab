extends SceneTree

const ACTIVE_SCENES: Array[PackedScene] = [
	preload("res://lab/lab_scene.tscn"),
	preload("res://battle/side_scroll_battle.tscn"),
	preload("res://kaiju/kaiju.tscn"),
	preload("res://enemies/melee_soldier.tscn"),
	preload("res://enemies/ranged_soldier.tscn"),
	preload("res://enemies/tank.tscn"),
	preload("res://enemies/drone.tscn"),
	preload("res://enemies/citadel_boss.tscn"),
]


func _initialize() -> void:
	for packed: PackedScene in ACTIVE_SCENES:
		var instance: Node = packed.instantiate()
		assert(instance is Node2D, "%s must have a 2D root" % packed.resource_path)
		assert(instance.find_children("*", "Node3D", true, false).is_empty(), "%s must not contain active 3D nodes" % packed.resource_path)
		instance.free()
	var battle: SideScrollBattle = ACTIVE_SCENES[1].instantiate() as SideScrollBattle
	root.add_child(battle)
	await process_frame
	assert(battle.camera is Camera2D)
	assert(battle.parallax.get_layers().size() == 5)
	print("PASS: active lab, battle, kaiju, enemies, camera, and parallax are native 2D")
	quit(0)
