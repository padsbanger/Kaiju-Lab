extends SceneTree

const SOLDIER: PackedScene = preload("res://enemies/melee_soldier.tscn")
const KAIJU: PackedScene = preload("res://kaiju/kaiju.tscn")


func _initialize() -> void:
	var kaiju: Kaiju = KAIJU.instantiate() as Kaiju
	var enemy: MeleeSoldier = SOLDIER.instantiate() as MeleeSoldier
	root.add_child(kaiju)
	root.add_child(enemy)
	await process_frame
	assert(enemy.feedback != null and enemy.feedback.bar != null, "Enemies must expose visible vitality feedback")
	var before: float = enemy.feedback.bar.value
	enemy.take_damage(12.0, kaiju)
	assert(enemy.feedback.bar.value < before)
	enemy.feedback.telegraph_action("STRIKE")
	assert(enemy.feedback.telegraph.visible and enemy.feedback.telegraph.text == "STRIKE")
	var torso: KaijuComponent = kaiju.anatomy_controller.get_component(&"torso_basic")
	torso.take_damage(torso.data.max_health * 0.4, enemy)
	assert(torso.visual.modulate != Color.WHITE, "Component wounds must have a visible state before destruction")
	print("PASS: enemy vitality, attack telegraph, and staged component wound readability")
	quit(0)
