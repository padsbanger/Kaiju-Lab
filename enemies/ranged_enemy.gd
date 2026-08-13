class_name RangedEnemy
extends CharacterBody3D

signal died(enemy: RangedEnemy)

@export var speed: float = 2.1
@export var preferred_distance: float = 6.0
@export var unit_name: String = "RANGED SOLDIER"
@onready var health: Health = $Health
@onready var attack: RangedAttack = $RangedAttack
var target: Node3D


func _ready() -> void:
	add_to_group(&"enemies")
	health.died.connect(_on_died)


func _physics_process(delta: float) -> void:
	if target == null or not is_instance_valid(target):
		target = get_tree().get_first_node_in_group(&"kaiju") as Node3D
		return
	var offset: Vector3 = target.global_position - global_position
	offset.y = 0.0
	if offset.length() > preferred_distance + 0.5:
		velocity = offset.normalized() * speed
	elif offset.length() < preferred_distance - 1.0:
		velocity = -offset.normalized() * speed * 0.65
	else:
		velocity = Vector3.ZERO
	attack.try_attack(target, self)
	if offset.length_squared() > 0.01:
		rotation.y = lerp_angle(rotation.y, atan2(offset.x, offset.z), minf(1.0, delta * 7.0))
	move_and_slide()


func take_damage(amount: float, source: Node = null) -> void:
	health.take_damage(amount, source)


func _on_died(_source: Node) -> void:
	remove_from_group(&"enemies")
	died.emit(self)
	queue_free()
