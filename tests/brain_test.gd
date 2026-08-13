extends SceneTree

const PREDATOR: BrainData = preload("res://data/brains/predator_brain.tres")
const BERSERKER: BrainData = preload("res://data/brains/berserker_brain.tres")


func _initialize() -> void:
	assert(PREDATOR.weakness_weight > BERSERKER.weakness_weight)
	assert(BERSERKER.distance_weight > PREDATOR.distance_weight)
	assert(PREDATOR.id != BERSERKER.id)
	print("PASS: shared utility brain supports distinct predator and berserker weighting")
	quit(0)
