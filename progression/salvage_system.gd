class_name SalvageSystem
extends RefCounted


static func generate_choices(result: BattleResult, threat_level: int) -> Array[SalvageChoice]:
	var multiplier := 1.0 + maxf(0.0, float(threat_level - 1) * 0.2)
	var recovery := SalvageChoice.new()
	recovery.choice_id = &"biomass_recovery"
	recovery.display_name = "RECLAIM TISSUE"
	recovery.description = "Prioritize regeneration biomass."
	recovery.biomass = roundi((result.biomass_reward + 22) * multiplier)

	var mutation := SalvageChoice.new()
	mutation.choice_id = &"mutation_culture"
	mutation.display_name = "CULTURE MUTAGENS"
	mutation.description = "Prioritize DNA for permanent mutations."
	mutation.dna = roundi((result.dna_reward + 4) * multiplier)
	mutation.biomass = roundi(result.biomass_reward * 0.25)

	var research := SalvageChoice.new()
	research.choice_id = &"combat_research"
	research.display_name = "ANALYZE COMBAT"
	research.description = "Prioritize specimen experience."
	research.experience = roundi((result.experience_reward + 35) * multiplier)
	research.biomass = roundi(result.biomass_reward * 0.35)
	return [recovery, mutation, research]

