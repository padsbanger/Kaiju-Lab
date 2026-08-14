class_name LabController
extends Node2D

const REGENERATION_SYSTEM_SCRIPT: Script = preload("res://progression/regeneration_system.gd")
const AUDIO_CUE_BUS_SCRIPT: Script = preload("res://audio/audio_cue_bus.gd")
const MAP_CATALOG: Script = preload("res://battle/map_catalog.gd")

signal deploy_requested
signal map_selected(map_data: BattleMapData)
signal new_specimen_requested
signal salvage_requested(index: int)

@onready var kaiju: Kaiju = %Kaiju
@onready var component_list: ItemList = %ComponentList
@onready var detail_label: Label = %DetailLabel
@onready var resource_label: Label = %ResourceLabel
@onready var deploy_button: Button = %DeployButton
@onready var repair_button: Button = %RepairButton
@onready var report_label: Label = %ReportLabel
@onready var organ_button: Button = %OrganButton
@onready var organ_selector: OptionButton = %OrganSelector
@onready var organ_preview: Label = %OrganPreview
@onready var map_selector: OptionButton = %MapSelector
@onready var mutation_selector: OptionButton = %MutationSelector
@onready var mutation_button: Button = %MutationButton
@onready var salvage_panel: PanelContainer = %SalvagePanel
@onready var salvage_buttons: Array[Button] = [%SalvageButton1, %SalvageButton2, %SalvageButton3]
var mutation_options: Array[MutationData] = [
	preload("res://data/mutations/acid_gland.tres"),
	preload("res://data/mutations/bone_plating.tres"),
	preload("res://data/mutations/regeneration_tumor.tres"),
]
@onready var level_button: Button = %LevelButton
var specimen: SpecimenState
var latest_result: BattleResult
var regeneration: RefCounted = REGENERATION_SYSTEM_SCRIPT.new()
var audio_cues: Node
var inspected_component_id: StringName = &""


func _ready() -> void:
	audio_cues = AUDIO_CUE_BUS_SCRIPT.new()
	add_child(audio_cues)
	kaiju.set_physics_process(false)
	kaiju.brain_controller.set_physics_process(false)
	kaiju.pixel_animation.set_state(PixelAnimationController.State.IDLE)
	component_list.item_selected.connect(_on_component_selected)
	deploy_button.pressed.connect(func() -> void: deploy_requested.emit())
	repair_button.pressed.connect(_repair_selected)
	organ_button.pressed.connect(_cycle_left_organ)
	organ_selector.item_selected.connect(_on_organ_preview_selected)
	map_selector.item_selected.connect(_on_map_selected)
	mutation_button.pressed.connect(_install_selected_mutation)
	%NewSpecimenButton.pressed.connect(func() -> void: new_specimen_requested.emit())
	level_button.pressed.connect(_level_up)
	for index: int in salvage_buttons.size():
		salvage_buttons[index].pressed.connect(_on_salvage_button_pressed.bind(index))


func bind_specimen(state: SpecimenState, result: BattleResult = null) -> void:
	specimen = state
	latest_result = result
	state.initialize_from_kaiju(kaiju)
	state.apply_to_kaiju(kaiju)
	_populate_maps()
	_populate_mutations()
	_populate_salvage()
	_refresh()


func refresh_after_salvage() -> void:
	_populate_salvage()
	_refresh()


func _on_salvage_button_pressed(index: int) -> void:
	salvage_requested.emit(index)


func _refresh() -> void:
	component_list.clear()
	var selected_index: int = 0
	for component: KaijuComponent in kaiju.anatomy_controller.components:
		component_list.add_item("%s  %d%%" % [component.data.display_name.to_upper(), int(component.ratio() * 100.0)])
		if component.data.id == inspected_component_id:
			selected_index = component_list.item_count - 1
	resource_label.text = "BIOMASS %d  DNA %d  ENERGY %d  // CIRCUIT %d THREAT %d\nSPECIMEN %s \"%s\"  LEVEL %d  XP %d/%d  DEPLOYMENTS %d  VICTORIES %d" % [specimen.biomass, specimen.dna, specimen.energy, specimen.circuit_level, specimen.threat_tier, specimen.specimen_id, specimen.display_name, specimen.level, specimen.experience, specimen.experience_to_next_level, specimen.total_deployments, specimen.total_victories]
	deploy_button.disabled = not regeneration.can_deploy(specimen)
	if specimen.has_pending_salvage():
		deploy_button.disabled = true
	deploy_button.text = "DEPLOY" if not deploy_button.disabled else "REGENERATION REQUIRED"
	if specimen.has_pending_salvage():
		deploy_button.text = "SELECT SALVAGE BEFORE DEPLOYMENT"
	report_label.text = "%s\n\n%s" % [specimen.build_analysis(), _battle_report()]
	level_button.disabled = not specimen.can_level_up()
	level_button.text = "LEVEL UP" if not level_button.disabled else "LEVEL UP // %d XP NEEDED" % maxi(0, specimen.experience_to_next_level - specimen.experience)
	if component_list.item_count > 0:
		component_list.select(selected_index)
		_on_component_selected(selected_index)


func _on_component_selected(index: int) -> void:
	if index < 0 or index >= kaiju.anatomy_controller.components.size():
		return
	var component: KaijuComponent = kaiju.anatomy_controller.components[index]
	inspected_component_id = component.data.id
	var status: String = "OFFLINE" if component.is_destroyed else ("DAMAGED" if component.ratio() < 1.0 else "HEALTHY")
	var dependencies: String = "NONE" if component.data.required_functions.is_empty() else ", ".join(component.data.required_functions)
	var operation: String = kaiju.anatomy_controller.offline_reason(component)
	detail_label.text = "%s\n%s\n\nFUNCTION  %s\nSOCKET    %s\nMASS      %.1f\nHEALTH    %.0f / %.0f\nSTATUS    %s\nSUPPLY    %s\nREQUIRES  %s\nENERGY    %+.1f / %.1f\nTAGS      %s" % [component.data.display_name.to_upper(), component.data.description, component.data.function_id, component.data.attachment_type, component.data.mass, component.current_health, component.data.max_health, status, operation, dependencies, component.data.energy_generation, component.data.energy_consumption, ", ".join(component.data.tags)]
	var state: ComponentState = specimen.component_states.get(component.data.id) as ComponentState
	repair_button.disabled = state == null or is_equal_approx(state.current_health, state.max_health) or specimen.biomass < regeneration.repair_cost(state)
	repair_button.text = "REGENERATE  %d BIOMASS" % regeneration.repair_cost(state) if state != null else "REGENERATE"
	_populate_organ_selector(state)


func _repair_selected() -> void:
	var selected: PackedInt32Array = component_list.get_selected_items()
	if selected.is_empty():
		return
	var component: KaijuComponent = kaiju.anatomy_controller.components[selected[0]]
	if regeneration.repair(specimen, component.data.id):
		audio_cues.play(&"regeneration")
		specimen.apply_to_kaiju(kaiju)
		kaiju.pixel_animation.set_state(PixelAnimationController.State.REGENERATING)
		_refresh()


func _battle_report() -> String:
	if latest_result == null:
		return "NO PREVIOUS DEPLOYMENT\nALL SYSTEMS AWAITING BASELINE"
	var damaged: Array[String] = []
	for component_id: StringName in latest_result.component_health:
		var state: ComponentState = specimen.component_states.get(component_id) as ComponentState
		if state != null and state.current_health < state.max_health:
			damaged.append("%s %d%% // %s" % [String(component_id).to_upper(), int(state.health_ratio() * 100.0), state.last_damage_cause])
	var damage_text: String = "NO LASTING DAMAGE" if damaged.is_empty() else "\n".join(damaged)
	return "BATTLE REPORT // %d%% PROGRESS // %d HOSTILES\n+%d XP  +%d BIOMASS  +%d DNA\n%s" % [int(latest_result.map_progress * 100.0), latest_result.enemies_defeated, latest_result.experience_reward, latest_result.biomass_reward, latest_result.dna_reward, damage_text]


func _populate_salvage() -> void:
	salvage_panel.visible = specimen != null and specimen.has_pending_salvage()
	if specimen == null:
		return
	for index: int in salvage_buttons.size():
		var button: Button = salvage_buttons[index]
		if index < specimen.pending_salvage_choices.size():
			var choice: SalvageChoiceData = specimen.pending_salvage_choices[index]
			button.visible = true
			button.text = "%s\n%s\n%s" % [choice.display_name, choice.summary(), choice.description]
		else:
			button.visible = false


func _cycle_left_organ() -> void:
	var state: ComponentState = specimen.component_states.get(inspected_component_id) as ComponentState
	if state == null or organ_selector.selected < 0:
		return
	var next_path: String = organ_selector.get_item_metadata(organ_selector.selected) as String
	if specimen.install_organ(inspected_component_id, next_path):
		specimen.apply_to_kaiju(kaiju)
		_refresh()


func _populate_organ_selector(state: ComponentState) -> void:
	organ_selector.clear()
	if state == null:
		organ_button.disabled = true
		organ_preview.text = "NO REPLACEABLE ORGAN SELECTED"
		return
	var selected_index: int = 0
	for candidate: ComponentData in specimen.compatible_organs(state.component_id):
		var path: String = candidate.resource_path
		organ_selector.add_item(candidate.display_name.to_upper())
		var index: int = organ_selector.item_count - 1
		organ_selector.set_item_metadata(index, path)
		if path == state.installed_resource_path:
			selected_index = index
	organ_selector.select(selected_index)
	_on_organ_preview_selected(selected_index)


func _on_organ_preview_selected(index: int) -> void:
	if specimen == null or index < 0 or index >= organ_selector.item_count:
		return
	var path: String = organ_selector.get_item_metadata(index) as String
	var candidate: ComponentData = load(path) as ComponentData
	var state: ComponentState = specimen.component_states.get(inspected_component_id) as ComponentState
	organ_preview.text = specimen.organ_comparison(inspected_component_id, path)
	organ_button.text = "INSTALL // %s // %d BIOMASS" % [candidate.display_name.to_upper(), candidate.installation_cost]
	organ_button.disabled = state == null or state.installed_resource_path == path or specimen.biomass < candidate.installation_cost


func _populate_maps() -> void:
	map_selector.clear()
	for map_data: BattleMapData in MAP_CATALOG.all_maps():
		if map_data.is_unlocked_for(specimen):
			map_selector.add_item("%s // %d CLEARS" % [map_data.display_name, specimen.map_clear_count(map_data.map_id)])
			map_selector.set_item_metadata(map_selector.item_count - 1, map_data)


func _on_map_selected(index: int) -> void:
	if index < 0 or index >= map_selector.item_count:
		return
	map_selected.emit(map_selector.get_item_metadata(index) as BattleMapData)


func _populate_mutations() -> void:
	mutation_selector.clear()
	for mutation: MutationData in mutation_options:
		if mutation.id not in specimen.mutation_ids:
			mutation_selector.add_item("%s // %d DNA" % [mutation.display_name.to_upper(), mutation_cost(mutation)])
			mutation_selector.set_item_metadata(mutation_selector.item_count - 1, mutation)
	mutation_button.disabled = mutation_selector.item_count == 0


func mutation_cost(mutation: MutationData) -> int:
	return 20 + int(absf(mutation.magnitude) * 2.0)


func _install_selected_mutation() -> void:
	if mutation_selector.selected < 0:
		return
	var mutation: MutationData = mutation_selector.get_item_metadata(mutation_selector.selected) as MutationData
	var cost: int = mutation_cost(mutation)
	if mutation == null or specimen.dna < cost:
		return
	specimen.dna -= cost
	specimen.mutation_ids.append(mutation.id)
	specimen.apply_to_kaiju(kaiju)
	_refresh()


func _level_up() -> void:
	if specimen.level_up():
		audio_cues.play(&"level_up")
		_refresh()
