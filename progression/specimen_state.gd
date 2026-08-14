class_name SpecimenState
extends Resource

signal state_changed

const MAX_ENERGY: float = 100.0
const MAX_BLOOD: float = 100.0
const MAX_OXYGEN: float = 100.0
const MAX_HEAT: float = 100.0
const CRITICAL_SUPPLY: float = 12.0

@export var specimen_name: String = "SUBJECT K-01"
@export var level: int = 1
@export var experience: int = 0
@export var biomass: int = 120
@export var dna: int = 0
@export var energy: float = MAX_ENERGY
@export var blood: float = MAX_BLOOD
@export var oxygen: float = MAX_OXYGEN
@export var heat: float = 0.0
@export var components: Dictionary[StringName, ComponentState] = {}
@export var mutations: PackedStringArray = []

var _available_functions: Dictionary[StringName, bool] = {}


func initialize_default() -> void:
	components.clear()
	for socket: StringName in ComponentCatalog.default_loadout():
		components[socket] = ComponentState.create(ComponentCatalog.default_loadout()[socket])
	refresh_anatomy()
	state_changed.emit()


func refresh_anatomy() -> void:
	_available_functions.clear()
	for state: ComponentState in components.values():
		state.offline_reason = "destroyed" if state.is_destroyed() else "dependency unavailable"
	for _pass: int in range(components.size() + 1):
		var changed := false
		for state: ComponentState in components.values():
			if state.is_destroyed() or state.offline_reason.is_empty():
				continue
			if not _requirements_met(state.definition):
				continue
			if state.definition.blood_demand > 0.0 and blood < CRITICAL_SUPPLY:
				state.offline_reason = "blood supply critical"
				continue
			if state.definition.oxygen_demand > 0.0 and oxygen < CRITICAL_SUPPLY:
				state.offline_reason = "oxygen supply critical"
				continue
			state.offline_reason = ""
			for provided: String in state.definition.provides_functions:
				_available_functions[StringName(provided)] = true
			changed = true
		if not changed:
			break


func simulate(delta: float, is_moving: bool = true) -> void:
	refresh_anatomy()
	var circulation := 0.0
	var oxygenation := 0.0
	var generated_energy := 0.0
	var resting_use := 0.0
	var blood_demand := 0.0
	var oxygen_demand := 0.0
	for state: ComponentState in components.values():
		if not state.offline_reason.is_empty():
			continue
		var definition := state.definition
		circulation += definition.circulation_output
		oxygenation += definition.oxygenation_output
		generated_energy += definition.energy_generation
		resting_use += definition.resting_energy_use
		blood_demand += definition.blood_demand
		oxygen_demand += definition.oxygen_demand
	var movement_demand := 4.0 if is_moving else 0.0
	var blood_target := clampf((circulation - blood_demand - movement_demand) * 5.0 + 50.0, 0.0, MAX_BLOOD)
	var oxygen_target := clampf((oxygenation - oxygen_demand - movement_demand * 0.5) * 5.0 + 50.0, 0.0, MAX_OXYGEN)
	blood = move_toward(blood, blood_target, delta * 28.0)
	oxygen = move_toward(oxygen, oxygen_target, delta * 24.0)
	energy = clampf(energy + (generated_energy - resting_use - movement_demand * 0.25) * delta, 0.0, MAX_ENERGY)
	heat = move_toward(heat, 0.0, delta * 7.0)
	refresh_anatomy()
	state_changed.emit()


func try_activate(socket: StringName) -> bool:
	refresh_anatomy()
	var state: ComponentState = components.get(socket)
	if state == null or not state.offline_reason.is_empty():
		return false
	var definition := state.definition
	if definition.attack_power <= 0.0:
		return false
	if energy < definition.activation_energy:
		state.offline_reason = "energy starved"
		return false
	if heat + definition.heat_per_activation > MAX_HEAT:
		state.offline_reason = "overheated"
		return false
	energy -= definition.activation_energy
	heat += definition.heat_per_activation
	state_changed.emit()
	return true


func apply_damage(socket: StringName, amount: float, cause: String) -> void:
	var state: ComponentState = components.get(socket)
	if state == null or amount <= 0.0:
		return
	state.health = maxf(0.0, state.health - amount)
	state.damage_cause = cause
	refresh_anatomy()
	state_changed.emit()


func repair_cost(socket: StringName) -> int:
	var state: ComponentState = components.get(socket)
	if state == null:
		return 0
	return ceili((state.definition.max_health - state.health) * state.definition.repair_cost_per_health)


func repair(socket: StringName) -> bool:
	var state: ComponentState = components.get(socket)
	var cost := repair_cost(socket)
	if state == null or cost <= 0 or biomass < cost:
		return false
	biomass -= cost
	state.health = state.definition.max_health
	state.damage_cause = ""
	refresh_anatomy()
	state_changed.emit()
	return true


func install(socket: StringName, definition: ComponentData) -> bool:
	if definition == null or definition.socket_type != socket or biomass < definition.installation_cost:
		return false
	biomass -= definition.installation_cost
	components[socket] = ComponentState.create(definition)
	refresh_anatomy()
	state_changed.emit()
	return true


func apply_mutation(mutation: MutationData) -> bool:
	if mutation == null or mutations.has(String(mutation.mutation_id)) or dna < mutation.dna_cost:
		return false
	dna -= mutation.dna_cost
	mutations.append(String(mutation.mutation_id))
	state_changed.emit()
	return true


func attack_multiplier() -> float:
	var multiplier := 1.0
	for mutation_id: String in mutations:
		var mutation := MutationCatalog.get_by_id(StringName(mutation_id))
		if mutation != null:
			multiplier *= mutation.attack_multiplier
	return multiplier


func damage_multiplier() -> float:
	var resistance := 0.0
	for mutation_id: String in mutations:
		var mutation := MutationCatalog.get_by_id(StringName(mutation_id))
		if mutation != null:
			resistance += mutation.damage_resistance
	return clampf(1.0 - resistance, 0.35, 1.0)


func has_function(function_name: StringName) -> bool:
	return _available_functions.has(function_name)


func movement_multiplier() -> float:
	if not has_function(&"structure"):
		return 0.0
	var supply := minf(blood / MAX_BLOOD, oxygen / MAX_OXYGEN)
	var circulation_factor := 1.0 if has_function(&"circulation") else 0.12
	var total_mass := 0.0
	for state: ComponentState in components.values():
		total_mass += state.definition.mass
	var mass_factor := clampf(1.2 - total_mass / 300.0, 0.55, 1.0)
	var mutation_factor := 1.0
	for mutation_id: String in mutations:
		var mutation := MutationCatalog.get_by_id(StringName(mutation_id))
		if mutation != null:
			mutation_factor *= mutation.movement_multiplier
	return clampf(supply * circulation_factor * mass_factor * mutation_factor, 0.0, 1.0)


func to_dictionary() -> Dictionary:
	var component_data := {}
	for socket: StringName in components:
		component_data[String(socket)] = components[socket].to_dictionary()
	return {
		"specimen_name": specimen_name,
		"level": level,
		"experience": experience,
		"biomass": biomass,
		"dna": dna,
		"energy": energy,
		"blood": blood,
		"oxygen": oxygen,
		"heat": heat,
		"mutations": Array(mutations),
		"components": component_data,
	}


static func from_dictionary(data: Dictionary) -> SpecimenState:
	var specimen := SpecimenState.new()
	specimen.specimen_name = str(data.get("specimen_name", "SUBJECT K-01"))
	specimen.level = maxi(1, int(data.get("level", 1)))
	specimen.experience = maxi(0, int(data.get("experience", 0)))
	specimen.biomass = maxi(0, int(data.get("biomass", 120)))
	specimen.dna = maxi(0, int(data.get("dna", 0)))
	specimen.energy = clampf(float(data.get("energy", MAX_ENERGY)), 0.0, MAX_ENERGY)
	specimen.blood = clampf(float(data.get("blood", MAX_BLOOD)), 0.0, MAX_BLOOD)
	specimen.oxygen = clampf(float(data.get("oxygen", MAX_OXYGEN)), 0.0, MAX_OXYGEN)
	specimen.heat = clampf(float(data.get("heat", 0.0)), 0.0, MAX_HEAT)
	specimen.mutations = PackedStringArray(data.get("mutations", []))
	var saved_components: Dictionary = data.get("components", {})
	for socket_key: String in saved_components:
		var saved_state: Dictionary = saved_components[socket_key]
		var definition := ComponentCatalog.get_by_id(StringName(saved_state.get("component_id", "")))
		if definition == null or definition.socket_type != StringName(socket_key):
			continue
		var state := ComponentState.create(definition)
		state.health = clampf(float(saved_state.get("health", definition.max_health)), 0.0, definition.max_health)
		state.damage_cause = str(saved_state.get("damage_cause", ""))
		specimen.components[StringName(socket_key)] = state
	if specimen.components.is_empty():
		specimen.initialize_default()
	else:
		specimen.refresh_anatomy()
	return specimen


func _requirements_met(definition: ComponentData) -> bool:
	for required: String in definition.required_functions:
		if not _available_functions.has(StringName(required)):
			return false
	return true
