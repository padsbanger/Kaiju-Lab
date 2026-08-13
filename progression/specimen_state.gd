class_name SpecimenState
extends Resource

@export var specimen_id: StringName = &"K-01"
@export var display_name: String = "MYCORAPTUS"
@export var level: int = 1
@export var experience: int = 0
@export var experience_to_next_level: int = 300
@export var biomass: int = 250
@export var dna: int = 50
@export var energy: int = 100
@export var component_states: Dictionary[StringName, ComponentState] = {}
@export var installed_component_paths: Dictionary[StringName, String] = {}
@export var mutation_ids: Array[StringName] = []


func initialize_from_kaiju(kaiju: Kaiju) -> void:
	if not component_states.is_empty():
		return
	for component: KaijuComponent in kaiju.anatomy_controller.components:
		var state := ComponentState.new()
		state.component_id = component.data.id
		state.current_health = component.current_health
		state.max_health = component.data.max_health
		state.installed_resource_path = component.data.resource_path
		component_states[state.component_id] = state
		installed_component_paths[state.component_id] = state.installed_resource_path


func capture_from_kaiju(kaiju: Kaiju) -> void:
	for component: KaijuComponent in kaiju.anatomy_controller.components:
		var state: ComponentState = component_states.get(component.data.id) as ComponentState
		if state == null:
			state = ComponentState.new()
			state.component_id = component.data.id
			component_states[state.component_id] = state
		state.current_health = component.current_health
		state.max_health = component.data.max_health
		state.installed_resource_path = component.data.resource_path


func apply_to_kaiju(kaiju: Kaiju) -> void:
	for component: KaijuComponent in kaiju.anatomy_controller.components:
		var state: ComponentState = component_states.get(component.data.id) as ComponentState
		if state == null:
			continue
		component.restore_state(state.current_health, state.max_health)


func add_rewards(xp: int, biomass_reward: int, dna_reward: int) -> void:
	experience += maxi(0, xp)
	biomass += maxi(0, biomass_reward)
	dna += maxi(0, dna_reward)


func damaged_component_count() -> int:
	var count: int = 0
	for state: ComponentState in component_states.values():
		if state.current_health < state.max_health:
			count += 1
	return count
