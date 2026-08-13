class_name MovementController
extends Node

@export var speed: float = 3.4
@export var stopping_distance: float = 90.0


func update_movement(body: CharacterBody2D, target: Node2D, delta: float) -> void:
	if target == null or not is_instance_valid(target):
		body.velocity = body.velocity.move_toward(Vector2.ZERO, speed * 40.0 * delta)
		body.move_and_slide()
		return
	var offset: Vector2 = target.global_position - body.global_position
	if offset.length() > stopping_distance:
		body.velocity = offset.normalized() * speed * 40.0
	else:
		body.velocity = Vector2.ZERO
	body.move_and_slide()
