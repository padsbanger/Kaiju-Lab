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


func _ready() -> void:
	add_to_group(&"kaiju")
	assert(component_root != null, "Kaiju requires a component root")
	assert(head_socket != null, "Kaiju requires a head socket")
	assert(left_arm_socket != null, "Kaiju requires a left arm socket")
	assert(right_arm_socket != null, "Kaiju requires a right arm socket")
	health.died.connect(_on_died)


func _physics_process(delta: float) -> void:
	if health.is_dead:
		return
	var target: Node3D = brain_controller.target if is_instance_valid(brain_controller.target) else null
	movement_controller.update_movement(self, target, delta)
	if target != null:
		claw_attack.try_attack(target)


func take_damage(amount: float, source: Node = null) -> void:
	health.take_damage(amount, source)


func _on_died(source: Node) -> void:
	died.emit(source)
	set_physics_process(false)
