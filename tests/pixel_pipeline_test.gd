extends SceneTree

const ASSETS: Array[String] = [
	"res://art/pixel/kaiju/torso.png",
	"res://art/pixel/kaiju/head.png",
	"res://art/pixel/kaiju/claw_arm.png",
	"res://art/pixel/kaiju/spore_gland.png",
]
const KAIJU_SCENE: PackedScene = preload("res://kaiju/kaiju.tscn")


func _initialize() -> void:
	assert(ProjectSettings.get_setting("display/window/size/viewport_width") == 640)
	assert(ProjectSettings.get_setting("display/window/size/viewport_height") == 360)
	for path: String in ASSETS:
		var texture: Texture2D = load(path) as Texture2D
		assert(texture != null)
		assert(texture.get_width() == 128 and texture.get_height() == 128)
	var kaiju: Kaiju = KAIJU_SCENE.instantiate() as Kaiju
	root.add_child(kaiju)
	await process_frame
	for visual: Node in kaiju.find_children("*", "ComponentVisual", true, false):
		assert((visual as ComponentVisual).texture_filter == BaseMaterial3D.TEXTURE_FILTER_NEAREST)
		assert((visual as ComponentVisual).billboard == BaseMaterial3D.BILLBOARD_DISABLED)
	print("PASS: low-resolution pixel assets, logical viewport, and nearest Sprite3D filtering")
	quit(0)
