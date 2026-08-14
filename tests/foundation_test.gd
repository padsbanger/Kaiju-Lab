extends SceneTree

const MAIN_SCENE: PackedScene = preload("res://main.tscn")
const FORBIDDEN_TYPES: PackedStringArray = [
	"Node3D", "Camera3D", "Sprite3D", "Area3D", "CharacterBody3D",
	"CollisionShape3D", "ParallaxBackground", "ParallaxLayer",
]


func _initialize() -> void:
	assert(ProjectSettings.get_setting("display/window/size/viewport_width") == 640)
	assert(ProjectSettings.get_setting("display/window/size/viewport_height") == 360)
	assert(ProjectSettings.get_setting("rendering/textures/canvas_textures/default_texture_filter") == 0)
	var main: Node = MAIN_SCENE.instantiate()
	assert(main is Node2D)
	_check_tree(main)
	main.free()
	print("PASS: native 2D pixel foundation")
	quit(0)


func _check_tree(node: Node) -> void:
	for forbidden_type: String in FORBIDDEN_TYPES:
		assert(not node.is_class(forbidden_type), "%s must not appear in the active runtime" % forbidden_type)
	for child: Node in node.get_children():
		_check_tree(child)

