class_name SalvageChoice
extends Resource

@export var choice_id: StringName
@export var display_name: String
@export var description: String
@export var biomass: int = 0
@export var dna: int = 0
@export var experience: int = 0


func to_dictionary() -> Dictionary:
	return {
		"choice_id": String(choice_id),
		"display_name": display_name,
		"description": description,
		"biomass": biomass,
		"dna": dna,
		"experience": experience,
	}


static func from_dictionary(data: Dictionary) -> SalvageChoice:
	var choice := SalvageChoice.new()
	choice.choice_id = StringName(data.get("choice_id", ""))
	choice.display_name = str(data.get("display_name", "Unknown Salvage"))
	choice.description = str(data.get("description", ""))
	choice.biomass = maxi(0, int(data.get("biomass", 0)))
	choice.dna = maxi(0, int(data.get("dna", 0)))
	choice.experience = maxi(0, int(data.get("experience", 0)))
	return choice

