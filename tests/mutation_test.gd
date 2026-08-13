extends SceneTree

const KAIJU_SCENE: PackedScene = preload("res://kaiju/kaiju.tscn")
const ACID: MutationData = preload("res://data/mutations/acid_gland.tres")
const PLATING: MutationData = preload("res://data/mutations/bone_plating.tres")
const REGEN: MutationData = preload("res://data/mutations/regeneration_tumor.tres")


func _initialize() -> void:
	var kaiju: Kaiju = KAIJU_SCENE.instantiate() as Kaiju
	var system := MutationSystem.new()
	root.add_child(kaiju)
	root.add_child(system)
	await process_frame
	var base_spit: float = kaiju.spit_attack.damage
	assert(system.apply_mutation(kaiju, ACID))
	assert(kaiju.spit_attack.damage > base_spit)
	assert(kaiju.get_node("ComponentRoot/MutationSocket").get_child_count() == 1)
	assert(system.apply_mutation(kaiju, PLATING))
	assert(kaiju.damage_resistance > 0.0)
	assert(system.apply_mutation(kaiju, REGEN))
	assert(kaiju.regeneration_amount > 20.0)
	assert(not system.apply_mutation(kaiju, ACID), "Duplicate mutation must not apply")
	print("PASS: three distinct mutation effects, visible addition, and duplicate guard")
	quit(0)
