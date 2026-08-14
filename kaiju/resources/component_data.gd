class_name ComponentData
extends Resource

@export var id: StringName
@export var display_name: String
@export_multiline var description: String
@export var max_health: float = 50.0
@export var mass: float = 10.0
@export var tags: Array[StringName] = []
@export var attachment_type: StringName
@export var function_id: StringName
@export var critical: bool = false
@export var energy_generation: float = 0.0
@export var energy_consumption: float = 0.0
@export var required_functions: Array[StringName] = []
@export var blood_demand: float = 0.0
@export var oxygen_demand: float = 0.0
@export var function_output: float = 1.0
@export var passive_heat: float = 0.0
@export var movement_multiplier: float = 1.0
@export var incoming_damage_multiplier: float = 1.0
@export var installation_cost: int = 0
@export var brain_profile: BrainData
