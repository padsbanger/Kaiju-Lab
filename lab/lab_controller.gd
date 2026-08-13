class_name LabController
extends Node2D

const REGENERATION_SYSTEM_SCRIPT: Script = preload("res://progression/regeneration_system.gd")
const AUDIO_CUE_BUS_SCRIPT: Script = preload("res://audio/audio_cue_bus.gd")

signal deploy_requested

@onready var kaiju: Kaiju = %Kaiju
@onready var component_list: ItemList = %ComponentList
@onready var detail_label: Label = %DetailLabel
@onready var resource_label: Label = %ResourceLabel
@onready var deploy_button: Button = %DeployButton
@onready var repair_button: Button = %RepairButton
@onready var report_label: Label = %ReportLabel
@onready var organ_button: Button = %OrganButton
@onready var level_button: Button = %LevelButton
var specimen: SpecimenState
var latest_result: BattleResult
var regeneration: RefCounted = REGENERATION_SYSTEM_SCRIPT.new()
var audio_cues: Node


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
	level_button.pressed.connect(_level_up)


func bind_specimen(state: SpecimenState, result: BattleResult = null) -> void:
	specimen = state
	latest_result = result
	state.initialize_from_kaiju(kaiju)
	state.apply_to_kaiju(kaiju)
	_refresh()


func _refresh() -> void:
	component_list.clear()
	for component: KaijuComponent in kaiju.anatomy_controller.components:
		component_list.add_item("%s  %d%%" % [component.data.display_name.to_upper(), int(component.ratio() * 100.0)])
	resource_label.text = "BIOMASS %d    DNA %d    ENERGY %d\nSPECIMEN %s \"%s\"    LEVEL %d    XP %d/%d" % [specimen.biomass, specimen.dna, specimen.energy, specimen.specimen_id, specimen.display_name, specimen.level, specimen.experience, specimen.experience_to_next_level]
	deploy_button.disabled = not regeneration.can_deploy(specimen)
	deploy_button.text = "DEPLOY" if not deploy_button.disabled else "REGENERATION REQUIRED"
	report_label.text = _battle_report()
	level_button.disabled = not specimen.can_level_up()
	level_button.text = "LEVEL UP" if not level_button.disabled else "LEVEL UP // %d XP NEEDED" % maxi(0, specimen.experience_to_next_level - specimen.experience)
	var left_state: ComponentState = specimen.component_states.get(&"claw_left") as ComponentState
	if left_state != null:
		var installed: ComponentData = load(left_state.installed_resource_path) as ComponentData
		organ_button.text = "CHANGE ORGAN // %s" % installed.display_name.to_upper()
	if component_list.item_count > 0:
		component_list.select(0)
		_on_component_selected(0)


func _on_component_selected(index: int) -> void:
	if index < 0 or index >= kaiju.anatomy_controller.components.size():
		return
	var component: KaijuComponent = kaiju.anatomy_controller.components[index]
	var status: String = "OFFLINE" if component.is_destroyed else ("DAMAGED" if component.ratio() < 1.0 else "HEALTHY")
	detail_label.text = "%s\n%s\n\nFUNCTION  %s\nSOCKET    %s\nMASS      %.1f\nHEALTH    %.0f / %.0f\nSTATUS    %s\nTAGS      %s" % [component.data.display_name.to_upper(), component.data.description, component.data.function_id, component.data.attachment_type, component.data.mass, component.current_health, component.data.max_health, status, ", ".join(component.data.tags)]
	var state: ComponentState = specimen.component_states.get(component.data.id) as ComponentState
	repair_button.disabled = state == null or is_equal_approx(state.current_health, state.max_health) or specimen.biomass < regeneration.repair_cost(state)
	repair_button.text = "REGENERATE  %d BIOMASS" % regeneration.repair_cost(state) if state != null else "REGENERATE"


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


func _cycle_left_organ() -> void:
	var state: ComponentState = specimen.component_states.get(&"claw_left") as ComponentState
	if state == null:
		return
	var index: int = specimen.organ_inventory.find(state.installed_resource_path)
	var next_path: String = specimen.organ_inventory[(index + 1) % specimen.organ_inventory.size()]
	if specimen.install_organ(&"claw_left", next_path):
		specimen.apply_to_kaiju(kaiju)
		_refresh()


func _level_up() -> void:
	if specimen.level_up():
		audio_cues.play(&"level_up")
		_refresh()
