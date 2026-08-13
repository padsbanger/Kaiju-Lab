extends SceneTree

const SOLDIER_SCENE: PackedScene = preload("res://enemies/melee_soldier.tscn")
const KAIJU_SCENE: PackedScene = preload("res://kaiju/kaiju.tscn")


func _initialize() -> void:
	var kaiju: Kaiju = KAIJU_SCENE.instantiate() as Kaiju
	var enemy: MeleeSoldier = SOLDIER_SCENE.instantiate() as MeleeSoldier
	root.add_child(kaiju)
	root.add_child(enemy)
	enemy.target = kaiju
	kaiju.global_position = Vector2.ZERO
	enemy.global_position = Vector2(200.0, 0.0)
	await physics_frame
	await physics_frame
	assert((enemy.get_node("Body") as Sprite2D).flip_h, "Right-side enemy must face left toward kaiju")
	enemy.global_position = Vector2(-200.0, 0.0)
	await physics_frame
	await physics_frame
	assert(not (enemy.get_node("Body") as Sprite2D).flip_h, "Left-side enemy must face right toward kaiju")
	print("PASS: enemy sprites face the kaiju from either spawn side")
	quit(0)
