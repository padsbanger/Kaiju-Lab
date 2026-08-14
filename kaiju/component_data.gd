class_name ComponentData
extends Resource

@export var component_id: StringName
@export var display_name: String = "Unnamed Organ"
@export var description: String = ""
@export var socket_type: StringName
@export var max_health: float = 100.0
@export var mass: float = 10.0
@export var tags: PackedStringArray = []
@export var provides_functions: PackedStringArray = []
@export var required_functions: PackedStringArray = []
@export var energy_generation: float = 0.0
@export var resting_energy_use: float = 0.0
@export var activation_energy: float = 0.0
@export var blood_demand: float = 0.0
@export var oxygen_demand: float = 0.0
@export var circulation_output: float = 0.0
@export var oxygenation_output: float = 0.0
@export var heat_per_activation: float = 0.0
@export var attack_power: float = 0.0
@export var attack_range: float = 0.0
@export var attack_cooldown: float = 1.0
@export var repair_cost_per_health: float = 0.25
@export var installation_cost: int = 0


func provides(function_name: StringName) -> bool:
	return provides_functions.has(String(function_name))

