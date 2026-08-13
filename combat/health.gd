class_name Health
extends Node

signal health_changed(current_health: float, max_health: float)
signal died(source: Node)

@export var max_health: float = 100.0
var current_health: float
var is_dead: bool = false


func _ready() -> void:
	current_health = max_health
	health_changed.emit(current_health, max_health)


func take_damage(amount: float, source: Node = null) -> void:
	if is_dead or amount <= 0.0:
		return
	current_health = maxf(0.0, current_health - amount)
	health_changed.emit(current_health, max_health)
	if current_health <= 0.0:
		is_dead = true
		died.emit(source)


func heal(amount: float) -> float:
	if is_dead or amount <= 0.0:
		return 0.0
	var previous: float = current_health
	current_health = minf(max_health, current_health + amount)
	health_changed.emit(current_health, max_health)
	return current_health - previous


func reset() -> void:
	is_dead = false
	current_health = max_health
	health_changed.emit(current_health, max_health)


func ratio() -> float:
	return current_health / max_health if max_health > 0.0 else 0.0
