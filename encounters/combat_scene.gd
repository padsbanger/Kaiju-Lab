class_name CombatScene
extends Node3D

@onready var camera: Camera3D = %Camera3D


func _ready() -> void:
	camera.look_at(Vector3(0.0, 1.0, 0.0))
