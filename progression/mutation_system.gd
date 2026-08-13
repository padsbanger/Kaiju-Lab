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
		_:
			return false
	applied_mutations.append(mutation)
	mutation_added.emit(mutation)
	return true
