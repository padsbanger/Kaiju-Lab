class_name BrainController
extends Node

signal target_changed(target: Node2D)
signal action_selected(action: StringName, score: float)

@export var target_group: StringName = &"enemies"
@export var scan_interval: float = 0.35
@export var brain_data: BrainData
var target: Node2D
var _scan_remaining: float = 0.0


func _physics_process(delta: float) -> void:
	if target != null and not is_instance_valid(target):
		target = null
		target_changed.emit(null)
	_scan_remaining -= delta
	if _scan_remaining <= 0.0:
		_scan_remaining = scan_interval
		select_target()


func select_target() -> void:
	var owner_2d: Node2D = get_parent() as Node2D
	var best_target: Node2D
	var best_score: float = -INF
	for candidate_node: Node in get_tree().get_nodes_in_group(target_group):
		var candidate: Node2D = candidate_node as Node2D
		if candidate == null or not is_instance_valid(candidate):
			continue
		var health: Health = candidate.get_node_or_null("Health") as Health
		if health != null and health.is_dead:
			continue
		var distance: float = owner_2d.global_position.distance_to(candidate.global_position) / 40.0
		var distance_weight: float = brain_data.distance_weight if brain_data != null else 1.0
		var weakness_weight: float = brain_data.weakness_weight if brain_data != null else 15.0
		var score: float = 100.0 - distance * distance_weight
		if health != null:
			score += (1.0 - health.ratio()) * weakness_weight
		if score > best_score:
			best_score = score
			best_target = candidate
	if target != best_target:
		target = best_target
		target_changed.emit(target)
	if target != null:
		action_selected.emit(&"engage", best_score)


func set_brain(data: BrainData) -> void:
	brain_data = data
	select_target()
