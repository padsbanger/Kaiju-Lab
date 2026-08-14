class_name BattleResult
extends Resource

enum Outcome { VICTORY, KAIJU_DEAD, REQUIRED_ENEMIES_FAILED, BOSS_DEFEATED, ENCOUNTER_FAILED }

@export var outcome: Outcome = Outcome.ENCOUNTER_FAILED
@export var elapsed_seconds: float = 0.0
@export var map_progress: float = 0.0
@export var waves_survived: int = 0
@export var enemies_defeated: int = 0
@export var boss_defeated: bool = false
@export var experience_reward: int = 0
@export var biomass_reward: int = 0
@export var dna_reward: int = 0
@export var component_health: Dictionary[StringName, float] = {}
@export var damage_causes: Dictionary[StringName, String] = {}
@export var failure_reason: String = ""
@export var map_id: StringName
@export var threat_tier: int = 1
@export var circuit_completed: bool = false


func capture_components(kaiju: Kaiju) -> void:
	component_health.clear()
	for component: KaijuComponent in kaiju.anatomy_controller.components:
		component_health[component.data.id] = component.current_health
		damage_causes[component.data.id] = component.last_damage_cause


func apply_to_specimen(specimen: SpecimenState) -> void:
	for component_id: StringName in component_health:
		var state: ComponentState = specimen.component_states.get(component_id) as ComponentState
		if state == null:
			continue
		state.current_health = clampf(component_health[component_id], 0.0, state.max_health)
		state.last_damage_cause = damage_causes.get(component_id, "Battle damage")
	specimen.add_rewards(experience_reward, biomass_reward, dna_reward)
