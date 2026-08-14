class_name SalvageSystem
extends RefCounted


static func generate_choices(result: BattleResult, map_id: StringName, threat_tier: int) -> Array[SalvageChoiceData]:
	var progress_factor: float = clampf(result.map_progress, 0.15, 1.0)
	var kill_factor: int = maxi(1, result.enemies_defeated)
	var threat_bonus: int = maxi(0, threat_tier - 1)
	var choices: Array[SalvageChoiceData] = []
	choices.append(_choice(
		&"biomass_cache", "BIOMASS CULTURE",
		"Feed recovered tissue into the regeneration vats. Best for rebuilding damaged anatomy.",
		18 + int(kill_factor * 2.2 * progress_factor) + threat_bonus * 6, 0, 0
	))
	choices.append(_choice(
		&"dna_archive", "GENETIC ARCHIVE",
		"Sequence unstable samples for mutations and advanced organ research.",
		0, 8 + result.waves_survived * 3 + (8 if result.boss_defeated else 0) + threat_bonus * 2, 0
	))
	var map_bonus: int = 20 if map_id == &"toxic_swamp" else 0
	choices.append(_choice(
		&"combat_study", "COMBAT AUTOPSY",
		"Trade usable tissue for behavioral data and faster specimen advancement.",
		0, 0, 70 + kill_factor * 8 + map_bonus + threat_bonus * 20
	))
	return choices


static func _choice(id: StringName, title: String, description: String, biomass: int, dna: int, xp: int) -> SalvageChoiceData:
	var choice := SalvageChoiceData.new()
	choice.id = id
	choice.display_name = title
	choice.description = description
	choice.biomass_reward = biomass
	choice.dna_reward = dna
	choice.experience_reward = xp
	return choice
