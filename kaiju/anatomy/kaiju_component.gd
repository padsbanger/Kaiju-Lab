class_name KaijuComponent
extends Area2D

signal health_changed(component: KaijuComponent, current: float, maximum: float)
signal component_destroyed(component: KaijuComponent)

@export var data: ComponentData
@export var visual_path: NodePath
var current_health: float
var is_destroyed: bool = false
var last_damage_cause: String = "No recorded damage"
@onready var visual: Sprite2D = get_node_or_null(visual_path) as Sprite2D


func _ready() -> void:
	assert(data != null, "KaijuComponent requires ComponentData")
	current_health = data.max_health
	add_to_group(&"kaiju_components")
	health_changed.emit(self, current_health, data.max_health)


func take_damage(amount: float, source: Node = null) -> void:
	if is_destroyed or amount <= 0.0:
		return
	current_health = maxf(0.0, current_health - amount)
	last_damage_cause = _describe_source(source)
	health_changed.emit(self, current_health, data.max_health)
	_update_visual_state()
	if current_health <= 0.0:
		is_destroyed = true
		monitorable = false
		component_destroyed.emit(self)


func heal(amount: float) -> float:
	if is_destroyed or amount <= 0.0:
		return 0.0
	var previous: float = current_health
	current_health = minf(data.max_health, current_health + amount)
	health_changed.emit(self, current_health, data.max_health)
	_update_visual_state()
	return current_health - previous


func ratio() -> float:
	return current_health / data.max_health if data.max_health > 0.0 else 0.0


func reset() -> void:
	is_destroyed = false
	monitorable = true
	current_health = data.max_health
	last_damage_cause = "No recorded damage"
	health_changed.emit(self, current_health, data.max_health)
	_update_visual_state()


func restore_state(saved_health: float, saved_max_health: float = -1.0) -> void:
	var maximum: float = data.max_health if saved_max_health <= 0.0 else saved_max_health
	current_health = clampf(saved_health, 0.0, maximum)
	is_destroyed = current_health <= 0.0
	monitorable = not is_destroyed
	health_changed.emit(self, current_health, maximum)
	_update_visual_state()


func _update_visual_state() -> void:
	if visual == null:
		return
	if is_zero_approx(current_health):
		visual.modulate = Color(0.18, 0.18, 0.2, 0.42)
	elif ratio() <= 0.5:
		visual.modulate = Color(1.0, 0.38, 0.42, 0.92)
	elif ratio() <= 0.75:
		visual.modulate = Color(1.0, 0.72, 0.42, 0.96)
	else:
		visual.modulate = Color.WHITE


func _describe_source(source: Node) -> String:
	if source == null:
		return "Unknown trauma"
	if source.is_in_group(&"boss"):
		return "Boss pressure: %s" % source.name
	if source.is_in_group(&"enemies"):
		return "Enemy attack: %s" % source.name
	return source.name if not source.name.is_empty() else "Battle trauma"
