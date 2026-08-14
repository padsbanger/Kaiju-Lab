class_name SalvageChoiceData
extends Resource

@export var id: StringName
@export var display_name: String
@export_multiline var description: String
@export var biomass_reward: int = 0
@export var dna_reward: int = 0
@export var experience_reward: int = 0


func summary() -> String:
	var rewards: Array[String] = []
	if biomass_reward > 0:
		rewards.append("+%d BIOMASS" % biomass_reward)
	if dna_reward > 0:
		rewards.append("+%d DNA" % dna_reward)
	if experience_reward > 0:
		rewards.append("+%d XP" % experience_reward)
	return "  ".join(rewards)


func to_save_data() -> Dictionary:
	return {
		"id": String(id),
		"display_name": display_name,
		"description": description,
		"biomass": biomass_reward,
		"dna": dna_reward,
		"experience": experience_reward,
	}


static func from_save_data(data: Dictionary) -> SalvageChoiceData:
	var choice := SalvageChoiceData.new()
	choice.id = StringName(str(data.get("id", "salvage")))
	choice.display_name = str(data.get("display_name", "RECOVERED MATERIAL"))
	choice.description = str(data.get("description", "Recovered deployment material."))
	choice.biomass_reward = maxi(0, int(data.get("biomass", 0)))
	choice.dna_reward = maxi(0, int(data.get("dna", 0)))
	choice.experience_reward = maxi(0, int(data.get("experience", 0)))
	return choice
