extends SceneTree

const KAIJU_SCENE: PackedScene = preload("res://kaiju/kaiju.tscn")


func _initialize() -> void:
	var kaiju: Kaiju = KAIJU_SCENE.instantiate() as Kaiju
	root.add_child(kaiju)
	await process_frame
	var resources: ResourceController = kaiju.resource_controller
	assert(resources.status_summary() == "METABOLISM STABLE")
	var start_energy: float = resources.energy
	assert(resources.consume_energy(12.0, 8.0))
	assert(resources.energy < start_energy and resources.heat > 10.0, "Powered actions must consume energy and generate heat")
	resources.energy = 2.0
	assert(not resources.consume_energy(8.0, 2.0), "Energy-starved organs must not activate")
	resources.energy = resources.maximum_energy
	resources.heat = resources.maximum_heat
	assert(not resources.consume_energy(1.0), "Overheated organs must not activate")
	resources.heat = 10.0
	var heart: KaijuComponent = kaiju.anatomy_controller.get_component(&"heart_basic")
	var claw: KaijuComponent = kaiju.anatomy_controller.get_component(&"claw_left")
	assert(kaiju.anatomy_controller.is_component_operational(claw))
	heart.take_damage(9999.0)
	assert(not kaiju.anatomy_controller.is_component_operational(claw), "Circulatory failure must disable dependent weapon organs")
	assert(kaiju.anatomy_controller.offline_reason(claw) == "CIRCULATION OFFLINE")
	for step: int in 90:
		resources._physics_process(1.0 / 60.0)
	assert(resources.blood < 90.0 and resources.movement_factor() < 0.7, "Circulatory collapse must drain supply and reduce movement")
	assert(resources.telemetry().contains("ENERGY") and resources.telemetry().contains("OXYGEN"))
	print("PASS: energy, heat, circulation, dependency failure, telemetry, and movement supply")
	quit(0)
