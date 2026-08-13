class_name RegenerationSystem
extends RefCounted

const BIOMASS_PER_HEALTH: float = 0.5


func repair_cost(state: ComponentState) -> int:
	return ceili(maxf(0.0, state.max_health - state.current_health) * BIOMASS_PER_HEALTH)


func repair(specimen: SpecimenState, component_id: StringName) -> bool:
	var state: ComponentState = specimen.component_states.get(component_id) as ComponentState
	if state == null or is_equal_approx(state.current_health, state.max_health):
		return false
	var cost: int = repair_cost(state)
	if specimen.biomass < cost:
		return false
	specimen.biomass -= cost
	state.current_health = state.max_health
	state.last_damage_cause = "Regenerated in laboratory"
	return true


func readiness_report(specimen: SpecimenState) -> String:
	var critical_offline: Array[String] = []
	for state: ComponentState in specimen.component_states.values():
		if state.is_destroyed() and state.component_id in [&"torso_basic", &"brain_predator", &"heart_basic"]:
			critical_offline.append(String(state.component_id).to_upper())
	return "READY" if critical_offline.is_empty() else "BLOCKED: REGENERATE %s" % ", ".join(critical_offline)


func can_deploy(specimen: SpecimenState) -> bool:
	return readiness_report(specimen) == "READY"
