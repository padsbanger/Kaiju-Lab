class_name KaijuLabMain
extends Node2D

const BATTLE_SCENE: PackedScene = preload("res://battle/side_scroll_battle.tscn")

@onready var lab: LabController = $Lab

var specimen: SpecimenState
var active_battle: SideScrollBattle


func _ready() -> void:
	get_viewport().canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	specimen = SpecimenState.new()
	specimen.initialize_default()
	lab.bind_specimen(specimen)
	lab.deployment_requested.connect(_on_deployment_requested)


func _on_deployment_requested(prepared_specimen: SpecimenState) -> void:
	if active_battle != null:
		return
	lab.visible = false
	active_battle = BATTLE_SCENE.instantiate()
	add_child(active_battle)
	active_battle.bind_specimen(prepared_specimen)
	active_battle.battle_finished.connect(_on_battle_finished)


func _on_battle_finished(_victory: bool) -> void:
	active_battle.queue_free()
	active_battle = null
	lab.visible = true
	lab.bind_specimen(specimen)
	lab.status_label.text = "SPECIMEN RECOVERED // REVIEW ORGAN DAMAGE"

