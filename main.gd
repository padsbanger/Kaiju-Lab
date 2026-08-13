class_name Main
extends Node

signal prototype_event(message: String)

@onready var status_label: Label = %StatusLabel
@onready var health_bar: ProgressBar = %HealthBar
@onready var combat_scene: CombatScene = $CombatScene


func _ready() -> void:
	combat_scene.status_changed.connect(report_event)
	combat_scene.kaiju_health_changed.connect(_on_kaiju_health_changed)
	report_event("SPECIMEN K-01 // ARENA LINK STABLE")


func report_event(message: String) -> void:
	status_label.text = message
	prototype_event.emit(message)
	print("[KaijuLab] ", message)


func _on_kaiju_health_changed(current: float, maximum: float) -> void:
	health_bar.max_value = maximum
	health_bar.value = current
