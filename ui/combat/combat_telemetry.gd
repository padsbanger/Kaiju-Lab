class_name CombatTelemetry
extends PanelContainer

@onready var brain_label: Label = %BrainLabel
@onready var biomass_label: Label = %BiomassLabel
@onready var anatomy_label: Label = %AnatomyLabel
var kaiju: Kaiju


func bind(specimen: Kaiju) -> void:
	kaiju = specimen
	kaiju.resource_controller.resource_changed.connect(_on_resource_changed)
	kaiju.anatomy_controller.component_health_changed.connect(_on_component_changed)
	kaiju.anatomy_controller.component_destroyed.connect(_on_component_destroyed)
	refresh()


func refresh() -> void:
	if kaiju == null:
		return
	var brain: BrainData = kaiju.brain_controller.brain_data
	brain_label.text = "BRAIN // %s" % (brain.display_name if brain != null else "UNKNOWN")
	biomass_label.text = "BIOMASS // %d / %d" % [int(kaiju.resource_controller.biomass), int(kaiju.resource_controller.maximum_biomass)]
	var online: int = 0
	for component: KaijuComponent in kaiju.anatomy_controller.components:
		if not component.is_destroyed:
			online += 1
	anatomy_label.text = "ANATOMY // %d / %d ONLINE" % [online, kaiju.anatomy_controller.components.size()]


func _on_resource_changed(_resource: StringName, _current: float, _maximum: float) -> void:
	refresh()


func _on_component_changed(_component: KaijuComponent, _current: float, _maximum: float) -> void:
	refresh()


func _on_component_destroyed(_component: KaijuComponent) -> void:
	refresh()
