class_name BattleResult
extends Resource

@export var victory: bool = false
@export var map_id: StringName
@export var progress: float = 0.0
@export var enemies_defeated: int = 0
@export var waves_reached: int = 0
@export var elapsed_seconds: float = 0.0
@export var biomass_reward: int = 0
@export var dna_reward: int = 0
@export var experience_reward: int = 0
@export var component_damage: Dictionary = {}


func to_dictionary() -> Dictionary:
	return {
		"victory": victory,
		"map_id": String(map_id),
		"progress": progress,
		"enemies_defeated": enemies_defeated,
		"waves_reached": waves_reached,
		"elapsed_seconds": elapsed_seconds,
		"biomass_reward": biomass_reward,
		"dna_reward": dna_reward,
		"experience_reward": experience_reward,
		"component_damage": component_damage.duplicate(true),
	}

