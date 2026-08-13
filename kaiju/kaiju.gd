class_name Kaiju
extends CharacterBody3D

signal died(source: Node)

@onready var component_root: Node3D = %ComponentRoot
@onready var head_socket: Node3D = %HeadSocket
@onready var left_arm_socket: Node3D = %LeftArmSocket
@onready var right_arm_socket: Node3D = %RightArmSocket
@onready var health: Health = $Health
@onready var brain_controller: BrainController = $BrainController
@onready var movement_controller: MovementController = $MovementController
@onready var claw_attack: MeleeAttack = $ClawAttack
@onready var anatomy_controller: AnatomyController = $AnatomyController
@onready var spit_attack: RangedAttack = $SpitAttack
@onready var resource_controller: ResourceController = $ResourceController
@onready var pixel_animation: PixelAnimationController = $PixelAnimationController
var regeneration_cooldown: float = 0.0
var regeneration_amount: float = 20.0
var regeneration_biomass_cost: float = 12.0
var damage_resistance: float = 0.0
var run_movement_speed: float = 3.4


func _ready() -> void:
	add_to_group(&"kaiju")
	assert(component_root != null, "Kaiju requires a component root")
	assert(head_socket != null, "Kaiju requires a head socket")
	assert(left_arm_socket != null, "Kaiju requires a left arm socket")
	assert(right_arm_socket != null, "Kaiju requires a right arm socket")
	health.died.connect(_on_died)
	anatomy_controller.register_tree(component_root)
	anatomy_controller.component_destroyed.connect(_on_component_destroyed)
	anatomy_controller.critical_failure.connect(_on_critical_failure)
	run_movement_speed = movement_controller.speed


func _physics_process(delta: float) -> void:
	if health.is_dead:
		return
	var target: Node3D = brain_controller.target if is_instance_valid(brain_controller.target) else null
	movement_controller.update_movement(self, target, delta)
	pixel_animation.set_state(PixelAnimationController.State.WALK if velocity.length_squared() > 0.1 else PixelAnimationController.State.IDLE)
	if target != null:
		var distance: float = global_position.distance_to(target.global_position)
		if distance <= 2.4 and anatomy_controller.is_function_online(&"melee_weapon"):
			if claw_attack.try_attack(target):
				pixel_animation.set_state(PixelAnimationController.State.ATTACK)
		elif distance > 2.4:
			spit_attack.try_attack(target, self)
	regeneration_cooldown = maxf(0.0, regeneration_cooldown - delta)
	if health.ratio() < 0.65 and regeneration_cooldown <= 0.0 and resource_controller.consume_biomass(regeneration_biomass_cost):
		health.heal(regeneration_amount)
		for component: KaijuComponent in anatomy_controller.get_damaged_components():
			component.heal(6.0)
		regeneration_cooldown = 4.0


func take_damage(amount: float, source: Node = null) -> void:
	health.take_damage(amount * (1.0 - damage_resistance), source)
	pixel_animation.set_state(PixelAnimationController.State.HURT)


func add_mutation_visual(mutation: MutationData) -> void:
	if mutation.visual_texture == null or %MutationSocket.get_child_count() > 0:
		return
	var sprite := ComponentVisual.new()
	sprite.texture = mutation.visual_texture
	sprite.component_id = mutation.id
	sprite.render_priority = 6
	sprite.scale = Vector3.ONE * 0.65
	%MutationSocket.add_child(sprite)


func add_plating_visual() -> void:
	var torso_visual: Sprite3D = $ComponentRoot/TorsoComponent/Visual
	torso_visual.modulate = Color(0.78, 0.82, 0.96, 1.0)
	torso_visual.scale *= 1.08


func add_regeneration_visual() -> void:
	var torso_visual: Sprite3D = $ComponentRoot/TorsoComponent/Visual
	torso_visual.modulate = Color(0.62, 1.0, 0.65, 1.0)


func add_extra_limb_visual(mutation: MutationData) -> void:
	if mutation.visual_texture == null:
		return
	var extra_socket: Node3D = Node3D.new()
	extra_socket.name = "AuxiliaryLimbSocket"
	extra_socket.position = Vector3(0.7, 1.75, 0.08)
	extra_socket.rotation.z = 0.95
	component_root.add_child(extra_socket)
	var sprite := ComponentVisual.new()
	sprite.texture = mutation.visual_texture
	sprite.component_id = mutation.id
	sprite.render_priority = 3
	sprite.scale = Vector3.ONE * 0.58
	extra_socket.add_child(sprite)


func set_run_movement_speed(value: float) -> void:
	run_movement_speed = value
	movement_controller.speed = value


func reset_for_encounter(spawn_position: Vector3) -> void:
	global_position = spawn_position
	velocity = Vector3.ZERO
	health.reset()
	resource_controller.biomass = 60.0
	resource_controller.resource_changed.emit(&"biomass", resource_controller.biomass, resource_controller.maximum_biomass)
	movement_controller.speed = run_movement_speed
	for component: KaijuComponent in anatomy_controller.components:
		component.reset()
	brain_controller.set_physics_process(true)
	set_physics_process(true)


func _on_died(source: Node) -> void:
	died.emit(source)
	set_physics_process(false)


func _on_component_destroyed(component: KaijuComponent) -> void:
	if component.data.function_id == &"brain":
		brain_controller.set_physics_process(false)
	if component.data.function_id == &"circulation":
		movement_controller.speed *= 0.45


func _on_critical_failure(component: KaijuComponent) -> void:
	health.take_damage(55.0 if component.data.function_id != &"structural" else health.max_health, component)
