class_name MutationCatalog
extends RefCounted

const BONE_PLATING: MutationData = preload("res://data/mutations/bone_plating.tres")
const METABOLIC_OVERDRIVE: MutationData = preload("res://data/mutations/metabolic_overdrive.tres")
const REGENERATION_TUMOR: MutationData = preload("res://data/mutations/regeneration_tumor.tres")

const ALL: Array[MutationData] = [BONE_PLATING, METABOLIC_OVERDRIVE, REGENERATION_TUMOR]


static func get_by_id(mutation_id: StringName) -> MutationData:
	for mutation: MutationData in ALL:
		if mutation.mutation_id == mutation_id:
			return mutation
	return null

