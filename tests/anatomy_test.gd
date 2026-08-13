extends SceneTree

const KAIJU_SCENE: PackedScene = preload("res://kaiju/kaiju.tscn")


func _initialize() -> void:
	var kaiju: Kaiju = KAIJU_SCENE.instantiate() as Kaiju
	root.add_child(kaiju)
	await process_frame
	var left_claw: KaijuComponent = kaiju.anatomy_controller.get_component(&"claw_left")
	assert(left_claw != null, "Left claw must be registered")
	left_claw.take_damage(left_claw.data.max_health)
	assert(left_claw.is_destroyed, "Left claw must be destroyed")
	assert(kaiju.anatomy_controller.is_function_online(&"melee_weapon"), "Right claw keeps melee online")
	var right_claw: KaijuComponent = kaiju.anatomy_controller.get_component(&"claw_right")
	right_claw.take_damage(right_claw.data.max_health)
	assert(not kaiju.anatomy_controller.is_function_online(&"melee_weapon"), "Both destroyed claws disable melee")
	var heart: KaijuComponent = kaiju.anatomy_controller.get_component(&"heart_basic")
	var speed_before: float = kaiju.movement_controller.speed
	heart.take_damage(heart.data.max_health)
	assert(kaiju.movement_controller.speed < speed_before, "Destroyed heart reduces movement")
	print("PASS: anatomy registration, visible component failure, and function shutdown")
	quit(0)
