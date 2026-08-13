class_name MovementController
extends Node

@export var speed: float = 3.4
@export var stopping_distance: float = 2.25


func update_movement(body: CharacterBody3D, target: Node3D, delta: float) -> void:
	if target == null or not is_instance_valid(target):
		body.velocity = body.velocity.move_toward(Vector3.ZERO, speed * 5.0 * delta)
		body.move_and_slide()
		return
	var offset: Vector3 = target.global_position - body.global_position
	offset.y = 0.0
	if offset.length() > stopping_distance:
		body.velocity = offset.normalized() * speed
	else:
		body.velocity = Vector3.ZERO
	if offset.length_squared() > 0.01:
		body.rotation.y = lerp_angle(body.rotation.y, atan2(offset.x, offset.z), minf(1.0, delta * 7.0))
	body.move_and_slide()
