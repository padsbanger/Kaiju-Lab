class_name AnatomyController
extends Node

signal component_registered(component: KaijuComponent)
signal component_health_changed(component: KaijuComponent, current: float, maximum: float)
signal component_destroyed(component: KaijuComponent)
signal critical_failure(component: KaijuComponent)

var components: Array[KaijuComponent] = []
var components_by_id: Dictionary[StringName, KaijuComponent] = {}


func register_tree(root: Node) -> void:
	components.clear()
	components_by_id.clear()
	for node: Node in root.find_children("*", "KaijuComponent", true, false):
		register_component(node as KaijuComponent)


func register_component(component: KaijuComponent) -> void:
	if component == null or component in components:
		return
	components.append(component)
	components_by_id[component.data.id] = component
	component.health_changed.connect(_on_component_health_changed)
	component.component_destroyed.connect(_on_component_destroyed)
	component_registered.emit(component)


func get_component(component_id: StringName) -> KaijuComponent:
	return components_by_id.get(component_id) as KaijuComponent


func is_function_online(function_id: StringName) -> bool:
	for component: KaijuComponent in components:
		if component.data.function_id == function_id and not component.is_destroyed:
			return true
	return false


func get_damaged_components() -> Array[KaijuComponent]:
	var damaged: Array[KaijuComponent] = []
	for component: KaijuComponent in components:
		if not component.is_destroyed and component.current_health < component.data.max_health:
			damaged.append(component)
	return damaged


func _on_component_health_changed(component: KaijuComponent, current: float, maximum: float) -> void:
	component_health_changed.emit(component, current, maximum)


func _on_component_destroyed(component: KaijuComponent) -> void:
	component_destroyed.emit(component)
	if component.data.critical:
		critical_failure.emit(component)
