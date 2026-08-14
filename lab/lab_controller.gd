class_name LabController
extends Node2D

signal deployment_requested(specimen: SpecimenState)

const SOCKET_ORDER: PackedStringArray = ["brain", "heart", "stomach", "torso", "arm_left", "arm_right"]

@onready var resources_label: Label = $Resources
@onready var detail_title: Label = $DetailPanel/Title
@onready var detail_body: Label = $DetailPanel/Body
@onready var comparison_label: Label = $DetailPanel/Comparison
@onready var candidate_option: OptionButton = $DetailPanel/Candidate
@onready var repair_button: Button = $DetailPanel/Repair
@onready var install_button: Button = $DetailPanel/Install
@onready var mutation_option: OptionButton = $MutationPanel/Mutation
@onready var mutation_description: Label = $MutationPanel/Description
@onready var mutate_button: Button = $MutationPanel/Mutate
@onready var deploy_button: Button = $Deploy
@onready var status_label: Label = $Status

var specimen: SpecimenState
var selected_socket: StringName = &"torso"


func _ready() -> void:
	for socket_name: String in SOCKET_ORDER:
		var button: Button = get_node("SocketPanel/%s" % socket_name)
		button.pressed.connect(select_socket.bind(StringName(socket_name)))
	candidate_option.item_selected.connect(_on_candidate_selected)
	repair_button.pressed.connect(repair_selected)
	install_button.pressed.connect(install_selected)
	mutation_option.item_selected.connect(_on_mutation_selected)
	mutate_button.pressed.connect(mutate_selected)
	deploy_button.pressed.connect(request_deployment)
	_populate_mutations()
	if specimen == null:
		var fresh_specimen := SpecimenState.new()
		fresh_specimen.initialize_default()
		bind_specimen(fresh_specimen)


func bind_specimen(new_specimen: SpecimenState) -> void:
	if specimen != null and specimen.state_changed.is_connected(_refresh):
		specimen.state_changed.disconnect(_refresh)
	specimen = new_specimen
	if specimen.components.is_empty():
		specimen.initialize_default()
	specimen.state_changed.connect(_refresh)
	_refresh()


func select_socket(socket: StringName) -> void:
	if specimen == null or not specimen.components.has(socket):
		return
	selected_socket = socket
	_refresh()


func repair_selected() -> bool:
	if specimen == null:
		return false
	var repaired := specimen.repair(selected_socket)
	status_label.text = "TISSUE REGENERATED" if repaired else "INSUFFICIENT BIOMASS / NO DAMAGE"
	return repaired


func install_selected() -> bool:
	if candidate_option.item_count == 0 or candidate_option.selected < 0:
		return false
	return install_component_by_id(StringName(candidate_option.get_item_metadata(candidate_option.selected)))


func install_component_by_id(component_id: StringName) -> bool:
	var definition := ComponentCatalog.get_by_id(component_id)
	var installed := specimen != null and specimen.install(selected_socket, definition)
	status_label.text = "ORGAN INSTALLED" if installed else "INCOMPATIBLE OR INSUFFICIENT BIOMASS"
	return installed


func mutate_selected() -> bool:
	if mutation_option.item_count == 0 or mutation_option.selected < 0:
		return false
	return apply_mutation_by_id(StringName(mutation_option.get_item_metadata(mutation_option.selected)))


func apply_mutation_by_id(mutation_id: StringName) -> bool:
	var applied := specimen != null and specimen.apply_mutation(MutationCatalog.get_by_id(mutation_id))
	status_label.text = "MUTATION STABILIZED" if applied else "MUTATION UNAVAILABLE"
	_refresh()
	return applied


func request_deployment() -> void:
	if specimen == null:
		return
	specimen.refresh_anatomy()
	if not specimen.has_function(&"structure") or not specimen.has_function(&"cognition"):
		status_label.text = "DEPLOYMENT BLOCKED: VITAL FUNCTION OFFLINE"
		return
	deployment_requested.emit(specimen)


func _refresh() -> void:
	if not is_node_ready() or specimen == null:
		return
	resources_label.text = "BIOMASS %03d   DNA %02d   LEVEL %02d" % [specimen.biomass, specimen.dna, specimen.level]
	var state: ComponentState = specimen.components.get(selected_socket)
	if state == null:
		return
	var definition := state.definition
	detail_title.text = "%s // %s" % [String(selected_socket).to_upper(), definition.display_name.to_upper()]
	var function_status := "ONLINE" if state.offline_reason.is_empty() else state.offline_reason.to_upper()
	detail_body.text = "%s\nHP  %d / %d    MASS  %.1f\nFUNCTION  %s\nREQUIRES  %s\nENERGY  +%.1f / -%.1f\nBLOOD %.1f   OXYGEN %.1f\nDAMAGE  %s" % [
		definition.description,
		int(state.health), int(definition.max_health), definition.mass,
		function_status,
		", ".join(definition.required_functions) if not definition.required_functions.is_empty() else "none",
		definition.energy_generation, definition.resting_energy_use,
		definition.blood_demand, definition.oxygen_demand,
		state.damage_cause if not state.damage_cause.is_empty() else "none",
	]
	repair_button.text = "REPAIR [%d BIO]" % specimen.repair_cost(selected_socket)
	repair_button.disabled = specimen.repair_cost(selected_socket) <= 0 or specimen.biomass < specimen.repair_cost(selected_socket)
	_populate_candidates(state)
	_update_mutation_description()
	for socket_name: String in SOCKET_ORDER:
		var socket_state: ComponentState = specimen.components.get(StringName(socket_name))
		var button: Button = get_node("SocketPanel/%s" % socket_name)
		button.text = "%s  %3d%%" % [socket_name.replace("_", " ").to_upper(), int(socket_state.health_ratio() * 100.0)]
		button.modulate = Color(1.0, 0.55, 0.5) if socket_state.is_destroyed() else Color.WHITE


func _populate_candidates(current_state: ComponentState) -> void:
	var previous_id: StringName = &""
	if candidate_option.item_count > 0 and candidate_option.selected >= 0:
		previous_id = StringName(candidate_option.get_item_metadata(candidate_option.selected))
	candidate_option.clear()
	for candidate: ComponentData in ComponentCatalog.compatible_with(selected_socket):
		if candidate.component_id == current_state.definition.component_id:
			continue
		candidate_option.add_item("%s  [%d]" % [candidate.display_name, candidate.installation_cost])
		var index := candidate_option.item_count - 1
		candidate_option.set_item_metadata(index, candidate.component_id)
		if candidate.component_id == previous_id:
			candidate_option.select(index)
	install_button.disabled = candidate_option.item_count == 0
	_update_comparison()


func _populate_mutations() -> void:
	mutation_option.clear()
	for mutation: MutationData in MutationCatalog.ALL:
		mutation_option.add_item("%s  [%d DNA]" % [mutation.display_name, mutation.dna_cost])
		mutation_option.set_item_metadata(mutation_option.item_count - 1, mutation.mutation_id)


func _update_comparison() -> void:
	if candidate_option.item_count == 0 or candidate_option.selected < 0:
		comparison_label.text = "NO ALTERNATIVE ORGAN AVAILABLE"
		return
	var current := specimen.components[selected_socket].definition
	var candidate := ComponentCatalog.get_by_id(StringName(candidate_option.get_item_metadata(candidate_option.selected)))
	comparison_label.text = "CANDIDATE Δ  HP %+d   MASS %+.1f   ENERGY %+.1f\nATTACK %+.1f   RANGE %+.0f   TAGS %s" % [
		int(candidate.max_health - current.max_health), candidate.mass - current.mass,
		(candidate.energy_generation - candidate.resting_energy_use) - (current.energy_generation - current.resting_energy_use),
		candidate.attack_power - current.attack_power, candidate.attack_range - current.attack_range,
		", ".join(candidate.tags),
	]
	install_button.text = "INSTALL [%d BIO]" % candidate.installation_cost
	install_button.disabled = specimen.biomass < candidate.installation_cost


func _update_mutation_description() -> void:
	if mutation_option.item_count == 0 or mutation_option.selected < 0:
		return
	var mutation := MutationCatalog.get_by_id(StringName(mutation_option.get_item_metadata(mutation_option.selected)))
	var acquired := specimen.mutations.has(String(mutation.mutation_id))
	mutation_description.text = mutation.description + ("\nACQUIRED" if acquired else "")
	mutate_button.disabled = acquired or specimen.dna < mutation.dna_cost


func _on_candidate_selected(_index: int) -> void:
	_update_comparison()


func _on_mutation_selected(_index: int) -> void:
	_update_mutation_description()
