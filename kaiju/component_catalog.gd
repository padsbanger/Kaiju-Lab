class_name ComponentCatalog
extends RefCounted

const BRAIN_PREDATOR: ComponentData = preload("res://data/components/brain_predator.tres")
const HEART_BASIC: ComponentData = preload("res://data/components/heart_basic.tres")
const STOMACH_BASIC: ComponentData = preload("res://data/components/stomach_basic.tres")
const TORSO_BASIC: ComponentData = preload("res://data/components/torso_basic.tres")
const CLAW_LEFT: ComponentData = preload("res://data/components/claw_left.tres")
const CLAW_RIGHT: ComponentData = preload("res://data/components/claw_right.tres")

const ALL: Array[ComponentData] = [
	BRAIN_PREDATOR,
	HEART_BASIC,
	STOMACH_BASIC,
	TORSO_BASIC,
	CLAW_LEFT,
	CLAW_RIGHT,
]


static func all_components() -> Array[ComponentData]:
	return ALL.duplicate()


static func get_by_id(component_id: StringName) -> ComponentData:
	for component: ComponentData in ALL:
		if component.component_id == component_id:
			return component
	return null


static func default_loadout() -> Dictionary[StringName, ComponentData]:
	return {
		&"brain": BRAIN_PREDATOR,
		&"heart": HEART_BASIC,
		&"stomach": STOMACH_BASIC,
		&"torso": TORSO_BASIC,
		&"arm_left": CLAW_LEFT,
		&"arm_right": CLAW_RIGHT,
	}

