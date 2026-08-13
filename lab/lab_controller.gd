class_name LabController
extends Node3D

signal deploy_requested

@onready var kaiju: Kaiju = %Kaiju
@onready var component_list: ItemList = %ComponentList
@onready var detail_label: Label = %DetailLabel
@onready var resource_label: Label = %ResourceLabel
@onready var deploy_button: Button = %DeployButton
var specimen: SpecimenState


func _ready() -> void:
	kaiju.set_physics_process(false)
	kaiju.brain_controller.set_physics_process(false)
	kaiju.pixel_animation.set_state(PixelAnimationController.State.IDLE)
	component_list.item_selected.connect(_on_component_selected)
	deploy_button.pressed.connect(func() -> void: deploy_requested.emit())
	%LabCamera.look_at(Vector3(0.0, 1.4, 0.0))


func bind_specimen(state: SpecimenState) -> void:
	specimen = state
	state.initialize_from_kaiju(kaiju)
	state.apply_to_kaiju(kaiju)
	_refresh()


func _refresh() -> void:
	component_list.clear()
	for component: KaijuComponent in kaiju.anatomy_controller.components:
		component_list.add_item("%s  %d%%" % [component.data.display_name.to_upper(), int(component.ratio() * 100.0)])
	resource_label.text = "BIOMASS %d    DNA %d    ENERGY %d\nSPECIMEN %s \"%s\"    LEVEL %d    XP %d/%d" % [specimen.biomass, specimen.dna, specimen.energy, specimen.specimen_id, specimen.display_name, specimen.level, specimen.experience, specimen.experience_to_next_level]
	if component_list.item_count > 0:
		component_list.select(0)
		_on_component_selected(0)


func _on_component_selected(index: int) -> void:
	if index < 0 or index >= kaiju.anatomy_controller.components.size():
		return
	var component: KaijuComponent = kaiju.anatomy_controller.components[index]
	var status: String = "OFFLINE" if component.is_destroyed else ("DAMAGED" if component.ratio() < 1.0 else "HEALTHY")
	detail_label.text = "%s\n%s\n\nFUNCTION  %s\nSOCKET    %s\nMASS      %.1f\nHEALTH    %.0f / %.0f\nSTATUS    %s\nTAGS      %s" % [component.data.display_name.to_upper(), component.data.description, component.data.function_id, component.data.attachment_type, component.data.mass, component.current_health, component.data.max_health, status, ", ".join(component.data.tags)]
