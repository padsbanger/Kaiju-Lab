class_name MeleeSoldier
extends CharacterBody3D

signal died(enemy: MeleeSoldier)

@export var speed: float = 2.4
@export var attack_distance: float = 1.8
@onready var health: Health = $Health
@onready var attack: MeleeAttack = $MeleeAttack
var target: Node3D


func _ready() -> void:
	add_to_group(&"enemies")
	health.died.connect(_on_died)


func _physics_process(delta: float) -> void:
	if health.is_dead:
		return
	if target == null or not is_instance_valid(target):
		target = get_tree().get_first_node_in_group(&"kaiju") as Node3D
		return
	var offset: Vector3 = target.global_position - global_position
	offset.y = 0.0
	if offset.length() > attack_distance:
		velocity = offset.normalized() * speed
	else:
		velocity = Vector3.ZERO
		attack.try_attack(target)
	if offset.length_squared() > 0.01:
		rotation.y = lerp_angle(rotation.y, atan2(offset.x, offset.z), minf(1.0, delta * 8.0))
	move_and_slide()


func take_damage(amount: float, source: Node = null) -> void:
	health.take_damage(amount, source)


func _on_died(_source: Node) -> void:
	remove_from_group(&"enemies")
	died.emit(self)
	set_physics_process(false)
	queue_free()
