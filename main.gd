class_name KaijuLabMain
extends Node2D

@onready var lab: LabController = $Lab

var specimen: SpecimenState


func _ready() -> void:
	get_viewport().canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	specimen = SpecimenState.new()
	specimen.initialize_default()
	lab.bind_specimen(specimen)
	lab.deployment_requested.connect(_on_deployment_requested)


func _on_deployment_requested(_prepared_specimen: SpecimenState) -> void:
	lab.status_label.text = "DEPLOYMENT CHAMBER ARMED // AWAITING BATTLE LINK"

