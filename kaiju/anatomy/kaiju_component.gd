class_name KaijuComponent
extends Area3D

signal health_changed(component: KaijuComponent, current: float, maximum: float)
signal component_destroyed(component: KaijuComponent)

@export var data: ComponentData
@export var visual_path: NodePath
var current_health: float
var is_destroyed: bool = false
@onready var visual: Sprite3D = get_node_or_null(visual_path) as Sprite3D


func _ready() -> void:
	assert(data != null, "KaijuComponent requires ComponentData")
	current_health = data.max_health
	add_to_group(&"kaiju_components")
	health_changed.emit(self, current_health, data.max_health)


func take_damage(amount: float, source: Node = null) -> void:
	if is_destroyed or amount <= 0.0:
		return
	current_health = maxf(0.0, current_health - amount)
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


func _update_visual_state() -> void:
	if visual == null:
		return
	if is_zero_approx(current_health):
		visual.modulate = Color(0.18, 0.18, 0.2, 0.42)
	elif ratio() <= 0.5:
		visual.modulate = Color(1.0, 0.38, 0.42, 0.92)
	else:
		visual.modulate = Color.WHITE
