class_name CombatProjectile
extends Area3D

@export var speed: float = 9.0
@export var damage: float = 12.0
@export var lifetime: float = 5.0
var direction: Vector3 = Vector3.FORWARD
var source: Node


func _ready() -> void:
	add_to_group(&"projectiles")
	body_entered.connect(_on_hit)
	area_entered.connect(_on_hit)


func launch(origin: Vector3, target_position: Vector3, attacker: Node, collision_targets: int) -> void:
	global_position = origin
	direction = origin.direction_to(target_position)
	source = attacker
	collision_mask = collision_targets


func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()


func _on_hit(target: Node3D) -> void:
	if target == source or (is_instance_valid(source) and source.is_ancestor_of(target)):
		return
	if target.has_method("take_damage"):
		target.take_damage(damage, source if is_instance_valid(source) else null)
		queue_free()
