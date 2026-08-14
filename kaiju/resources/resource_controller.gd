class_name ResourceController
extends Node

signal resource_changed(resource: StringName, current: float, maximum: float)
signal metabolic_state_changed(summary: String)

@export var maximum_biomass: float = 100.0
@export var biomass: float = 60.0
@export var maximum_energy: float = 100.0
@export var energy: float = 100.0
@export var maximum_blood: float = 100.0
@export var blood: float = 100.0
@export var maximum_oxygen: float = 100.0
@export var oxygen: float = 100.0
@export var maximum_heat: float = 100.0
@export var heat: float = 10.0
@export var basal_energy_drain: float = 0.35
@export var safe_heat: float = 72.0
var anatomy: AnatomyController
var movement_load: float = 0.0
var _last_summary: String = ""


func configure(owner_anatomy: AnatomyController) -> void:
	anatomy = owner_anatomy
	_emit_all()


func _physics_process(delta: float) -> void:
	if anatomy == null:
		return
	var circulation: float = anatomy.function_efficiency(&"circulation")
	var digestion: float = anatomy.function_efficiency(&"digestion")
	var structural: float = anatomy.function_efficiency(&"structural")
	blood = clampf(move_toward(blood, maximum_blood * circulation, delta * (16.0 if circulation > 0.0 else 10.0)), 0.0, maximum_blood)
	var oxygen_target: float = maximum_oxygen * minf(circulation, structural)
	var oxygen_rate: float = 13.0 * circulation - 5.0 * movement_load
	oxygen = clampf(oxygen + oxygen_rate * delta, 0.0, minf(maximum_oxygen, oxygen_target + 0.01))
	var supply: float = minf(blood / maximum_blood, oxygen / maximum_oxygen)
	var generated_energy: float = anatomy.total_online_property(&"energy_generation") * digestion * supply
	var organ_energy_drain: float = anatomy.total_online_property(&"energy_consumption") * 0.04
	var blood_demand: float = anatomy.total_online_property(&"blood_demand") * 0.015
	var oxygen_demand: float = anatomy.total_online_property(&"oxygen_demand") * 0.018
	blood = maxf(0.0, blood - blood_demand * delta)
	oxygen = maxf(0.0, oxygen - oxygen_demand * delta)
	energy = clampf(energy + (generated_energy - basal_energy_drain - organ_energy_drain - movement_load * 0.8) * delta, 0.0, maximum_energy)
	var passive_heat: float = anatomy.total_online_property(&"passive_heat")
	heat = clampf(heat + (movement_load * 4.0 + passive_heat - 2.2 * circulation) * delta, 0.0, maximum_heat)
	movement_load = move_toward(movement_load, 0.0, delta * 2.0)
	_emit_all()
	var next_summary: String = status_summary()
	if next_summary != _last_summary:
		_last_summary = next_summary
		metabolic_state_changed.emit(next_summary)


func set_movement_load(normalized_load: float) -> void:
	movement_load = maxf(movement_load, clampf(normalized_load, 0.0, 1.0))


func can_power(cost: float) -> bool:
	return energy >= cost and oxygen > 5.0 and blood > 5.0 and heat < maximum_heat


func consume_energy(amount: float, generated_heat: float = 0.0) -> bool:
	if amount <= 0.0:
		return true
	if not can_power(amount):
		return false
	energy -= amount
	heat = minf(maximum_heat, heat + maxf(0.0, generated_heat))
	_emit(&"energy", energy, maximum_energy)
	_emit(&"heat", heat, maximum_heat)
	return true


func movement_factor() -> float:
	if anatomy == null:
		return 1.0
	var circulation: float = anatomy.function_efficiency(&"circulation")
	var supply: float = minf(blood / maximum_blood, oxygen / maximum_oxygen)
	var heat_factor: float = clampf((maximum_heat - heat) / (maximum_heat - safe_heat), 0.2, 1.0) if heat > safe_heat else 1.0
	return clampf(circulation * supply * heat_factor, 0.15, 1.0)


func consume_biomass(amount: float) -> bool:
	if biomass < amount:
		return false
	biomass -= amount
	_emit(&"biomass", biomass, maximum_biomass)
	return true


func add_biomass(amount: float) -> void:
	biomass = minf(maximum_biomass, biomass + amount)
	_emit(&"biomass", biomass, maximum_biomass)


func reset_for_deployment(starting_biomass: float = 60.0) -> void:
	biomass = clampf(starting_biomass, 0.0, maximum_biomass)
	energy = maximum_energy
	blood = maximum_blood
	oxygen = maximum_oxygen
	heat = 10.0
	_emit_all()


func status_summary() -> String:
	if blood <= 5.0:
		return "CIRCULATORY COLLAPSE"
	if oxygen <= 5.0:
		return "ANOXIA"
	if heat >= safe_heat:
		return "OVERHEATING"
	if energy <= 10.0:
		return "ENERGY STARVATION"
	return "METABOLISM STABLE"


func telemetry() -> String:
	return "ENERGY %03d  BLOOD %03d  OXYGEN %03d  HEAT %03d" % [int(energy), int(blood), int(oxygen), int(heat)]


func _emit_all() -> void:
	_emit(&"biomass", biomass, maximum_biomass)
	_emit(&"energy", energy, maximum_energy)
	_emit(&"blood", blood, maximum_blood)
	_emit(&"oxygen", oxygen, maximum_oxygen)
	_emit(&"heat", heat, maximum_heat)


func _emit(id: StringName, current: float, maximum: float) -> void:
	resource_changed.emit(id, current, maximum)
