extends SceneTree

const ACTIVE_SCENES: Array[PackedScene] = [
	preload("res://main.tscn"),
	preload("res://lab/lab_scene.tscn"),
	preload("res://battle/side_scroll_battle.tscn"),
	preload("res://kaiju/kaiju_battle_actor.tscn"),
]
const FORBIDDEN: PackedStringArray = [
	"Node3D", "Camera3D", "Sprite3D", "Area3D", "CharacterBody3D",
	"CollisionShape3D", "ParallaxBackground", "ParallaxLayer",
]


func _initialize() -> void:
	for scene: PackedScene in ACTIVE_SCENES:
		var instance := scene.instantiate()
		_check_node(instance)
		instance.free()
	print("PASS: every active scene remains native 2D with modern Parallax2D")
	quit(0)


func _check_node(node: Node) -> void:
	for forbidden_type: String in FORBIDDEN:
		assert(not node.is_class(forbidden_type))
	for child: Node in node.get_children():
		_check_node(child)

