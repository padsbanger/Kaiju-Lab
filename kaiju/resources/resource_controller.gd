class_name ResourceController
extends Node

signal resource_changed(resource: StringName, current: float, maximum: float)

@export var maximum_biomass: float = 100.0
@export var biomass: float = 60.0


func consume_biomass(amount: float) -> bool:
	if biomass < amount:
		return false
	biomass -= amount
	resource_changed.emit(&"biomass", biomass, maximum_biomass)
	return true


func add_biomass(amount: float) -> void:
	biomass = minf(maximum_biomass, biomass + amount)
	resource_changed.emit(&"biomass", biomass, maximum_biomass)
