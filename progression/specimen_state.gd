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
@export var organ_inventory: Array[String] = [
	"res://data/components/claw_left.tres",
	"res://data/components/claw_tendril.tres",
	"res://data/components/claw_hammer.tres"
]


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
		if not state.installed_resource_path.is_empty():
			var installed: ComponentData = load(state.installed_resource_path) as ComponentData
			if installed != null and installed.attachment_type == component.data.attachment_type:
				component.data = installed
		component.restore_state(state.current_health, state.max_health)
	kaiju.apply_loadout_effects()


func add_rewards(xp: int, biomass_reward: int, dna_reward: int) -> void:
	experience += maxi(0, xp)
	biomass += maxi(0, biomass_reward)
	dna += maxi(0, dna_reward)


func can_level_up() -> bool:
	return experience >= experience_to_next_level


func level_up() -> bool:
	if not can_level_up():
		return false
	experience -= experience_to_next_level
	level += 1
	experience_to_next_level = int(experience_to_next_level * 1.35)
	energy += 10
	return true


func install_organ(component_id: StringName, resource_path: String) -> bool:
	var state: ComponentState = component_states.get(component_id) as ComponentState
	var replacement: ComponentData = load(resource_path) as ComponentData
	if state == null or replacement == null or resource_path not in organ_inventory:
		return false
	var current: ComponentData = load(state.installed_resource_path) as ComponentData
	if current == null or current.attachment_type != replacement.attachment_type:
		return false
	state.installed_resource_path = resource_path
	state.max_health = replacement.max_health
	state.current_health = minf(state.current_health, state.max_health)
	installed_component_paths[component_id] = resource_path
	return true


func damaged_component_count() -> int:
	var count: int = 0
	for state: ComponentState in component_states.values():
		if state.current_health < state.max_health:
			count += 1
	return count
