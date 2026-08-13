class_name Main
extends Node

signal prototype_event(message: String)

@onready var status_label: Label = %StatusLabel


func _ready() -> void:
	report_event("SYSTEM READY // INITIALIZING SPECIMEN BAY")


func report_event(message: String) -> void:
	status_label.text = message
	prototype_event.emit(message)
	print("[KaijuLab] ", message)
