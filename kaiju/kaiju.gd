class_name Kaiju
extends CharacterBody2D

signal died(source: Node)

@onready var component_root: Node2D = %ComponentRoot
@onready var head_socket: Node2D = %HeadSocket
@onready var left_arm_socket: Node2D = %LeftArmSocket
@onready var right_arm_socket: Node2D = %RightArmSocket
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
var loadout_movement_multiplier: float = 1.0
var loadout_damage_multiplier: float = 1.0


func _ready() -> void:
	add_to_group(&"kaiju")
	assert(component_root != null, "Kaiju requires a component root")
	assert(head_socket != null, "Kaiju requires a head socket")
	assert(left_arm_socket != null, "Kaiju requires a left arm socket")
	assert(right_arm_socket != null, "Kaiju requires a right arm socket")
	health.died.connect(_on_died)
	anatomy_controller.register_tree(component_root)
	resource_controller.configure(anatomy_controller)
	anatomy_controller.component_destroyed.connect(_on_component_destroyed)
	anatomy_controller.critical_failure.connect(_on_critical_failure)
	run_movement_speed = movement_controller.speed


func _physics_process(delta: float) -> void:
	if health.is_dead:
		return
	var target: Node2D = brain_controller.target if is_instance_valid(brain_controller.target) else null
	movement_controller.update_movement(self, target, delta)
	pixel_animation.set_state(PixelAnimationController.State.WALK if velocity.length_squared() > 0.1 else PixelAnimationController.State.IDLE)
	if target != null:
		var distance: float = global_position.distance_to(target.global_position)
		var melee_component: KaijuComponent = anatomy_controller.get_component(&"claw_left")
		if distance <= 96.0 and anatomy_controller.is_component_operational(melee_component):
			if claw_attack.try_attack(target):
				pixel_animation.set_state(PixelAnimationController.State.ATTACK)
		elif distance > 96.0:
			spit_attack.try_attack(target, self)
	resource_controller.set_movement_load(clampf(velocity.length() / maxf(1.0, movement_controller.speed * 40.0), 0.0, 1.0))
	regeneration_cooldown = maxf(0.0, regeneration_cooldown - delta)
	if health.ratio() < 0.65 and regeneration_cooldown <= 0.0 and resource_controller.consume_energy(12.0, 9.0) and resource_controller.consume_biomass(regeneration_biomass_cost):
		health.heal(regeneration_amount)
		for component: KaijuComponent in anatomy_controller.get_damaged_components():
			component.heal(6.0)
		regeneration_cooldown = 4.0


func take_damage(amount: float, source: Node = null) -> void:
	health.take_damage(amount * loadout_damage_multiplier * (1.0 - damage_resistance), source)
	pixel_animation.set_state(PixelAnimationController.State.HURT)


func add_mutation_visual(mutation: MutationData) -> void:
	if mutation.visual_texture == null or %MutationSocket.get_child_count() > 0:
		return
	var sprite := ComponentVisual.new()
	sprite.texture = mutation.visual_texture
	sprite.component_id = mutation.id
	sprite.z_index = 6
	sprite.scale = Vector2.ONE * 0.65
	%MutationSocket.add_child(sprite)


func add_plating_visual() -> void:
	var torso_visual: Sprite2D = $ComponentRoot/TorsoComponent/Visual
	torso_visual.modulate = Color(0.78, 0.82, 0.96, 1.0)
	torso_visual.scale *= 1.08


func add_regeneration_visual() -> void:
	var torso_visual: Sprite2D = $ComponentRoot/TorsoComponent/Visual
	torso_visual.modulate = Color(0.62, 1.0, 0.65, 1.0)


func add_extra_limb_visual(mutation: MutationData) -> void:
	if mutation.visual_texture == null:
		return
	var extra_socket: Node2D = Node2D.new()
	extra_socket.name = "AuxiliaryLimbSocket"
	extra_socket.position = Vector2(28.0, -70.0)
	extra_socket.rotation = 0.95
	component_root.add_child(extra_socket)
	var sprite := ComponentVisual.new()
	sprite.texture = mutation.visual_texture
	sprite.component_id = mutation.id
	sprite.z_index = 3
	sprite.scale = Vector2.ONE * 0.58
	extra_socket.add_child(sprite)


func set_run_movement_speed(value: float) -> void:
	run_movement_speed = value
	movement_controller.speed = value


func apply_loadout_effects() -> void:
	_reset_build_effects()
	loadout_movement_multiplier = 1.0
	loadout_damage_multiplier = 1.0
	for component: KaijuComponent in anatomy_controller.components:
		loadout_movement_multiplier *= component.data.movement_multiplier
		loadout_damage_multiplier *= component.data.incoming_damage_multiplier
		if component.data.function_id == &"brain" and component.data.brain_profile != null:
			brain_controller.set_brain(component.data.brain_profile)
	var left: KaijuComponent = $ComponentRoot/LeftArmSocket/ClawComponent
	var sprite: Sprite2D = left.get_node("Visual") as Sprite2D
	if &"tendril" in left.data.tags:
		claw_attack.damage = 17.0
		claw_attack.cooldown = 0.48
		sprite.scale = Vector2(0.72, 1.18)
		sprite.modulate = Color(0.86, 0.5, 1.0, 1.0)
	elif &"crusher" in left.data.tags:
		claw_attack.damage = 39.0
		claw_attack.cooldown = 1.25
		sprite.scale = Vector2(1.25, 1.25)
		sprite.modulate = Color(0.88, 0.84, 0.64, 1.0)
	elif &"siphon" in left.data.tags:
		claw_attack.damage = 13.0
		claw_attack.cooldown = 0.62
		claw_attack.energy_cost = 1.0
		sprite.scale = Vector2(0.65, 1.08)
		sprite.modulate = Color(0.78, 0.18, 0.38, 1.0)
	else:
		claw_attack.damage = 24.0
		claw_attack.cooldown = 0.82
		sprite.scale = Vector2(0.9, 0.9)
		sprite.modulate = Color.WHITE
		claw_attack.energy_cost = 4.0


func _reset_build_effects() -> void:
	damage_resistance = 0.0
	regeneration_amount = 20.0
	regeneration_biomass_cost = 12.0
	run_movement_speed = 3.4
	movement_controller.speed = run_movement_speed
	health.max_health = 180.0
	health.current_health = minf(health.current_health, health.max_health)
	resource_controller.maximum_biomass = 100.0
	resource_controller.biomass = minf(resource_controller.biomass, resource_controller.maximum_biomass)
	spit_attack.damage = 16.0
	spit_attack.cooldown = 1.75
	claw_attack.energy_cost = 4.0
	var torso_visual: Sprite2D = $ComponentRoot/TorsoComponent/Visual
	torso_visual.modulate = Color.WHITE
	torso_visual.scale = Vector2.ONE
	$ComponentRoot/HeadSocket/HeadComponent/Visual.modulate = Color.WHITE
	var auxiliary: Node = component_root.get_node_or_null("AuxiliaryLimbSocket")
	if auxiliary != null:
		component_root.remove_child(auxiliary)
		auxiliary.free()


func reset_for_encounter(spawn_position: Vector2) -> void:
	global_position = spawn_position
	velocity = Vector2.ZERO
	health.reset()
	resource_controller.reset_for_deployment(60.0)
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
