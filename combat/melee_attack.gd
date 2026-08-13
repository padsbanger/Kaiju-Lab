class_name MeleeAttack
extends Area3D

signal attack_started
signal attack_landed(target: Node, damage: float)

@export var damage: float = 20.0
@export var cooldown: float = 1.0
var cooldown_remaining: float = 0.0


func _physics_process(delta: float) -> void:
	cooldown_remaining = maxf(0.0, cooldown_remaining - delta)


func try_attack(preferred_target: Node3D = null) -> bool:
	if cooldown_remaining > 0.0:
		return false
	var candidates: Array[Node3D] = []
	for area: Area3D in get_overlapping_areas():
		if area.has_method("take_damage"):
			candidates.append(area)
	for body: Node3D in get_overlapping_bodies():
		if body.has_method("take_damage"):
			candidates.append(body)
	if candidates.is_empty():
		return false
	var target: Node3D = candidates[0]
	if preferred_target in candidates:
		target = preferred_target
	elif preferred_target != null:
		for candidate: Node3D in candidates:
			if preferred_target.is_ancestor_of(candidate):
				target = candidate
				break
	cooldown_remaining = cooldown
	attack_started.emit()
	target.take_damage(damage, get_parent())
	attack_landed.emit(target, damage)
	return true


func is_ready() -> bool:
	return cooldown_remaining <= 0.0
