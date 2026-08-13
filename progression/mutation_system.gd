class_name MutationSystem
extends Node

signal mutation_added(mutation: MutationData)

var applied_mutations: Array[MutationData] = []


func apply_mutation(kaiju: Kaiju, mutation: MutationData) -> bool:
	if mutation == null or mutation in applied_mutations:
		return false
	match mutation.effect_type:
		&"acid_gland":
			kaiju.spit_attack.damage += mutation.magnitude
			kaiju.spit_attack.cooldown = maxf(0.45, kaiju.spit_attack.cooldown - 0.35)
			kaiju.add_mutation_visual(mutation)
		&"bone_plating":
			kaiju.damage_resistance = clampf(kaiju.damage_resistance + mutation.magnitude, 0.0, 0.8)
			kaiju.set_run_movement_speed(maxf(1.0, kaiju.run_movement_speed - mutation.tradeoff))
			kaiju.add_plating_visual()
		&"regeneration_tumor":
			kaiju.regeneration_amount += mutation.magnitude
			kaiju.regeneration_biomass_cost += mutation.tradeoff
			kaiju.add_regeneration_visual()
		&"berserker_cortex":
			kaiju.brain_controller.set_brain(load("res://data/brains/berserker_brain.tres") as BrainData)
			kaiju.claw_attack.damage += mutation.magnitude
			kaiju.spit_attack.damage = maxf(1.0, kaiju.spit_attack.damage - mutation.tradeoff)
			kaiju.get_node("ComponentRoot/HeadSocket/HeadComponent/Visual").modulate = Color(1.0, 0.48, 0.58, 1.0)
		&"metabolic_overdrive":
			kaiju.resource_controller.maximum_biomass += mutation.magnitude
			kaiju.resource_controller.biomass += mutation.magnitude
			kaiju.health.max_health = maxf(60.0, kaiju.health.max_health - mutation.tradeoff)
			kaiju.health.current_health = minf(kaiju.health.current_health, kaiju.health.max_health)
			kaiju.get_node("ComponentRoot/TorsoComponent/Visual").modulate = Color(0.8, 1.0, 0.45, 1.0)
		&"extra_limb":
			kaiju.claw_attack.damage += mutation.magnitude
			kaiju.resource_controller.maximum_biomass = maxf(30.0, kaiju.resource_controller.maximum_biomass - mutation.tradeoff)
			kaiju.resource_controller.biomass = minf(kaiju.resource_controller.biomass, kaiju.resource_controller.maximum_biomass)
			kaiju.add_extra_limb_visual(mutation)
		_:
			return false
	applied_mutations.append(mutation)
	mutation_added.emit(mutation)
	return true
