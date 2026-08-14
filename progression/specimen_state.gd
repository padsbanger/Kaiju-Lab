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
@export var unlocked_map_ids: Array[StringName] = [&"city_ruins"]
@export var pending_salvage_choices: Array[SalvageChoiceData] = []
@export var pending_salvage_claimed: bool = true
@export var total_deployments: int = 0
@export var total_victories: int = 0
@export var circuit_level: int = 1
@export var threat_tier: int = 1
@export var map_victories: Dictionary[StringName, int] = {}
@export var circuit_cleared_map_ids: Array[StringName] = []
@export var organ_inventory: Array[String] = [
	"res://data/components/claw_left.tres",
	"res://data/components/claw_tendril.tres",
	"res://data/components/claw_hammer.tres",
	"res://data/components/claw_siphon.tres",
	"res://data/components/brain_predator.tres",
	"res://data/components/brain_sentinel.tres",
	"res://data/components/brain_scavenger.tres",
	"res://data/components/heart_basic.tres",
	"res://data/components/heart_hypercardiac.tres",
	"res://data/components/heart_redundant.tres",
	"res://data/components/stomach_basic.tres",
	"res://data/components/stomach_furnace.tres",
	"res://data/components/stomach_reservoir.tres",
	"res://data/components/torso_basic.tres",
	"res://data/components/torso_fortress.tres",
	"res://data/components/torso_hollow.tres"
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
	var system: MutationSystem = kaiju.get_node_or_null("PersistentMutationSystem") as MutationSystem
	if system == null:
		system = MutationSystem.new()
		system.name = "PersistentMutationSystem"
		kaiju.add_child(system)
	system.reset_applied()
	for mutation_id: StringName in mutation_ids:
		var mutation: MutationData = _mutation_by_id(mutation_id)
		if mutation != null:
			system.apply_mutation(kaiju, mutation)


func add_rewards(xp: int, biomass_reward: int, dna_reward: int) -> void:
	experience += maxi(0, xp)
	biomass += maxi(0, biomass_reward)
	dna += maxi(0, dna_reward)


func set_pending_salvage(choices: Array[SalvageChoiceData]) -> void:
	pending_salvage_choices = choices.duplicate()
	pending_salvage_claimed = pending_salvage_choices.is_empty()


func claim_salvage(index: int) -> bool:
	if pending_salvage_claimed or index < 0 or index >= pending_salvage_choices.size():
		return false
	var choice: SalvageChoiceData = pending_salvage_choices[index]
	add_rewards(choice.experience_reward, choice.biomass_reward, choice.dna_reward)
	pending_salvage_claimed = true
	pending_salvage_choices.clear()
	return true


func has_pending_salvage() -> bool:
	return not pending_salvage_claimed and not pending_salvage_choices.is_empty()


func record_map_victory(map_id: StringName, campaign_map_ids: Array[StringName]) -> bool:
	total_victories += 1
	map_victories[map_id] = map_victories.get(map_id, 0) + 1
	if map_id not in circuit_cleared_map_ids:
		circuit_cleared_map_ids.append(map_id)
	for required_id: StringName in campaign_map_ids:
		if required_id not in circuit_cleared_map_ids:
			return false
	circuit_level += 1
	threat_tier = mini(10, circuit_level)
	circuit_cleared_map_ids.clear()
	biomass += 40 + circuit_level * 5
	dna += 20 + circuit_level * 3
	return true


func map_clear_count(map_id: StringName) -> int:
	return map_victories.get(map_id, 0)


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
	if current == null or current.attachment_type != replacement.attachment_type or replacement.id != component_id:
		return false
	if state.installed_resource_path == resource_path or biomass < replacement.installation_cost:
		return false
	biomass -= replacement.installation_cost
	state.installed_resource_path = resource_path
	state.max_health = replacement.max_health
	state.current_health = minf(state.current_health, state.max_health)
	installed_component_paths[component_id] = resource_path
	return true


func compatible_organs(component_id: StringName) -> Array[ComponentData]:
	var options: Array[ComponentData] = []
	var state: ComponentState = component_states.get(component_id) as ComponentState
	if state == null:
		return options
	var installed: ComponentData = load(state.installed_resource_path) as ComponentData
	if installed == null:
		return options
	for path: String in organ_inventory:
		var candidate: ComponentData = load(path) as ComponentData
		if candidate != null and candidate.attachment_type == installed.attachment_type and candidate.id == component_id:
			options.append(candidate)
	return options


func organ_comparison(component_id: StringName, resource_path: String) -> String:
	var state: ComponentState = component_states.get(component_id) as ComponentState
	var candidate: ComponentData = load(resource_path) as ComponentData
	if state == null or candidate == null:
		return "NO COMPATIBLE ORGAN DATA"
	var current: ComponentData = load(state.installed_resource_path) as ComponentData
	if current == null or current.attachment_type != candidate.attachment_type:
		return "INCOMPATIBLE SOCKET"
	var dependencies: String = "NONE" if candidate.required_functions.is_empty() else ", ".join(candidate.required_functions)
	return "%s -> %s  // COST %d BIOMASS\nHEALTH %+.0f   MASS %+.0f\nENERGY USE %+.1f   GENERATION %+.1f\nBLOOD %+.1f  OXYGEN %+.1f  HEAT %+.1f\nREQUIRES %s\n%s" % [
		current.display_name.to_upper(), candidate.display_name.to_upper(),
		candidate.installation_cost,
		candidate.max_health - current.max_health, candidate.mass - current.mass,
		candidate.energy_consumption - current.energy_consumption,
		candidate.energy_generation - current.energy_generation,
		candidate.blood_demand - current.blood_demand,
		candidate.oxygen_demand - current.oxygen_demand,
		candidate.passive_heat - current.passive_heat,
		dependencies.to_upper(), candidate.description
	]


func build_analysis() -> String:
	var total_mass: float = 0.0
	var energy_generation: float = 0.0
	var energy_use: float = 0.0
	var blood_demand: float = 0.0
	var oxygen_demand: float = 0.0
	var tags: Array[StringName] = []
	for state: ComponentState in component_states.values():
		var component: ComponentData = load(state.installed_resource_path) as ComponentData
		if component == null:
			continue
		total_mass += component.mass
		energy_generation += component.energy_generation
		energy_use += component.energy_consumption
		blood_demand += component.blood_demand
		oxygen_demand += component.oxygen_demand
		for tag: StringName in component.tags:
			if tag not in tags:
				tags.append(tag)
	var archetype: String = "BALANCED PREDATOR"
	if &"crusher" in tags:
		archetype = "SIEGE BRUTE"
	elif &"siphon" in tags:
		archetype = "HEMOVORE"
	elif &"furnace" in tags:
		archetype = "METABOLIC OVERDRIVE"
	elif &"rapid" in tags:
		archetype = "RAPID STRIKER"
	elif &"fortress" in tags:
		archetype = "LIVING FORTRESS"
	var balance: float = energy_generation - energy_use
	var liability: String = "SUPPLY BALANCED"
	if balance < 0.0:
		liability = "ENERGY DEFICIT"
	elif blood_demand + oxygen_demand > 25.0:
		liability = "HIGH PERFUSION DEMAND"
	elif total_mass > 135.0:
		liability = "HEAVY FRAME"
	return "BUILD // %s\nMASS %.0f  ENERGY %+.1f  BLOOD %.1f  OXYGEN %.1f\n%s" % [archetype, total_mass, balance, blood_demand, oxygen_demand, liability]


func damaged_component_count() -> int:
	var count: int = 0
	for state: ComponentState in component_states.values():
		if state.current_health < state.max_health:
			count += 1
	return count


func to_save_data() -> Dictionary:
	var saved_components: Dictionary = {}
	for component_id: StringName in component_states:
		var state: ComponentState = component_states[component_id] as ComponentState
		saved_components[String(component_id)] = {
			"health": state.current_health,
			"max_health": state.max_health,
			"installed": state.installed_resource_path,
			"cause": state.last_damage_cause,
		}
	return {
		"specimen_id": String(specimen_id), "display_name": display_name,
		"level": level, "experience": experience, "experience_to_next_level": experience_to_next_level,
		"biomass": biomass, "dna": dna, "energy": energy,
		"mutations": mutation_ids.map(func(id: StringName) -> String: return String(id)),
		"inventory": organ_inventory.duplicate(),
		"unlocked_maps": unlocked_map_ids.map(func(id: StringName) -> String: return String(id)),
		"pending_salvage": pending_salvage_choices.map(func(choice: SalvageChoiceData) -> Dictionary: return choice.to_save_data()),
		"pending_salvage_claimed": pending_salvage_claimed,
		"total_deployments": total_deployments,
		"total_victories": total_victories,
		"circuit_level": circuit_level,
		"threat_tier": threat_tier,
		"map_victories": _string_key_dictionary(map_victories),
		"circuit_cleared_maps": circuit_cleared_map_ids.map(func(id: StringName) -> String: return String(id)),
		"components": saved_components,
	}


static func from_save_data(data: Dictionary) -> SpecimenState:
	var loaded := SpecimenState.new()
	loaded.specimen_id = StringName(str(data.get("specimen_id", "K-01")))
	loaded.display_name = str(data.get("display_name", "MYCORAPTUS"))
	loaded.level = maxi(1, int(data.get("level", 1)))
	loaded.experience = maxi(0, int(data.get("experience", 0)))
	loaded.experience_to_next_level = maxi(1, int(data.get("experience_to_next_level", 300)))
	loaded.biomass = maxi(0, int(data.get("biomass", 250)))
	loaded.dna = maxi(0, int(data.get("dna", 50)))
	loaded.energy = maxi(0, int(data.get("energy", 100)))
	loaded.mutation_ids.clear()
	for id: Variant in data.get("mutations", []): loaded.mutation_ids.append(StringName(str(id)))
	loaded.organ_inventory.clear()
	for path: Variant in data.get("inventory", []):
		if ResourceLoader.exists(str(path)): loaded.organ_inventory.append(str(path))
	if loaded.organ_inventory.is_empty():
		loaded.organ_inventory = SpecimenState.new().organ_inventory
	loaded.unlocked_map_ids.clear()
	for id: Variant in data.get("unlocked_maps", ["city_ruins"]): loaded.unlocked_map_ids.append(StringName(str(id)))
	loaded.pending_salvage_choices.clear()
	for saved_choice: Variant in data.get("pending_salvage", []):
		if saved_choice is Dictionary:
			loaded.pending_salvage_choices.append(SalvageChoiceData.from_save_data(saved_choice as Dictionary))
	loaded.pending_salvage_claimed = bool(data.get("pending_salvage_claimed", loaded.pending_salvage_choices.is_empty()))
	loaded.total_deployments = maxi(0, int(data.get("total_deployments", 0)))
	loaded.total_victories = maxi(0, int(data.get("total_victories", 0)))
	loaded.circuit_level = maxi(1, int(data.get("circuit_level", 1)))
	loaded.threat_tier = maxi(1, int(data.get("threat_tier", loaded.circuit_level)))
	loaded.map_victories.clear()
	var saved_victories: Dictionary = data.get("map_victories", {}) as Dictionary
	for map_id: String in saved_victories:
		loaded.map_victories[StringName(map_id)] = maxi(0, int(saved_victories[map_id]))
	loaded.circuit_cleared_map_ids.clear()
	for map_id: Variant in data.get("circuit_cleared_maps", []):
		loaded.circuit_cleared_map_ids.append(StringName(str(map_id)))
	var components: Dictionary = data.get("components", {}) as Dictionary
	for id: String in components:
		var values: Dictionary = components[id] as Dictionary
		var state := ComponentState.new()
		state.component_id = StringName(id)
		state.max_health = maxf(1.0, float(values.get("max_health", 1.0)))
		state.current_health = clampf(float(values.get("health", state.max_health)), 0.0, state.max_health)
		state.installed_resource_path = str(values.get("installed", ""))
		state.last_damage_cause = str(values.get("cause", "No recorded damage"))
		loaded.component_states[state.component_id] = state
		loaded.installed_component_paths[state.component_id] = state.installed_resource_path
	return loaded


func _string_key_dictionary(source: Dictionary[StringName, int]) -> Dictionary:
	var result: Dictionary = {}
	for key: StringName in source:
		result[String(key)] = source[key]
	return result


func _mutation_by_id(mutation_id: StringName) -> MutationData:
	const PATHS: Array[String] = [
		"res://data/mutations/acid_gland.tres", "res://data/mutations/bone_plating.tres",
		"res://data/mutations/regeneration_tumor.tres", "res://data/mutations/berserker_cortex.tres",
		"res://data/mutations/metabolic_overdrive.tres", "res://data/mutations/twin_claw_tendril.tres",
	]
	for path: String in PATHS:
		var mutation: MutationData = load(path) as MutationData
		if mutation != null and mutation.id == mutation_id:
			return mutation
	return null
