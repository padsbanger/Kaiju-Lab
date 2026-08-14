class_name MeleeAttack
extends Area2D

signal attack_started
signal attack_landed(target: Node, damage: float)

@export var damage: float = 20.0
@export var cooldown: float = 1.0
@export var energy_cost: float = 4.0
@export var heat_generated: float = 3.0
var cooldown_remaining: float = 0.0


func _physics_process(delta: float) -> void:
	cooldown_remaining = maxf(0.0, cooldown_remaining - delta)


func try_attack(preferred_target: Node2D = null) -> bool:
	if cooldown_remaining > 0.0:
		return false
	var candidates: Array[Node2D] = []
	for area: Area2D in get_overlapping_areas():
		if area.has_method("take_damage"):
			candidates.append(area)
	for body: Node2D in get_overlapping_bodies():
		if body.has_method("take_damage"):
			candidates.append(body)
	if candidates.is_empty():
		return false
	var resources: ResourceController = _find_resources()
	if resources != null and not resources.consume_energy(energy_cost, heat_generated):
		return false
	var target: Node2D = candidates[0]
	if preferred_target in candidates:
		target = preferred_target
	elif preferred_target != null:
		for candidate: Node2D in candidates:
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


func _find_resources() -> ResourceController:
	var owner_node: Node = get_parent()
	return owner_node.get_node_or_null("ResourceController") as ResourceController if owner_node != null else null
