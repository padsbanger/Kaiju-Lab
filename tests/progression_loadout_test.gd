extends SceneTree

const KAIJU_SCENE: PackedScene = preload("res://kaiju/kaiju.tscn")


func _initialize() -> void:
	var kaiju: Kaiju = KAIJU_SCENE.instantiate() as Kaiju
	root.add_child(kaiju)
	await process_frame
	var specimen := SpecimenState.new()
	specimen.initialize_from_kaiju(kaiju)
	specimen.add_rewards(450, 20, 10)
	assert(specimen.level_up() and specimen.level == 2 and specimen.energy == 110)
	assert(specimen.install_organ(&"claw_left", "res://data/components/claw_tendril.tres"))
	specimen.apply_to_kaiju(kaiju)
	var left: KaijuComponent = kaiju.get_node("ComponentRoot/LeftArmSocket/ClawComponent") as KaijuComponent
	assert(left.data.display_name == "Violet Tendril")
	assert(kaiju.claw_attack.cooldown == 0.48 and kaiju.claw_attack.damage == 17.0)
	var sprite: Sprite2D = left.get_node("Visual") as Sprite2D
	assert(sprite.scale.y > sprite.scale.x, "Tendril replacement must visibly change silhouette")
	assert(not specimen.install_organ(&"claw_left", "res://data/components/heart_basic.tres"), "Socket compatibility must be enforced")
	var options: Array[ComponentData] = specimen.compatible_organs(&"claw_left")
	assert(options.size() >= 4, "The arm socket must offer multiple meaningful build choices")
	var comparison: String = specimen.organ_comparison(&"claw_left", "res://data/components/claw_hammer.tres")
	assert(comparison.contains("HEALTH") and comparison.contains("MASS") and comparison.contains("ENERGY USE") and comparison.contains("REQUIRES"))
	print("PASS: rewards, level-up, compatible organ replacement, visual and behavior change")
	quit(0)
