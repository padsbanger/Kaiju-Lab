class_name ComponentHitArea
extends Area2D

@export var socket: StringName

var specimen: SpecimenState


func bind_specimen(value: SpecimenState) -> void:
	specimen = value


func receive_component_damage(amount: float, cause: String) -> void:
	if specimen != null:
		specimen.apply_damage(socket, amount * specimen.damage_multiplier(), cause)

