extends SceneTree

const PARALLAX_SCENE: PackedScene = preload("res://levels/city_ruins/city_ruins_parallax.tscn")


func _initialize() -> void:
	var parallax: PixelParallaxController = PARALLAX_SCENE.instantiate() as PixelParallaxController
	root.add_child(parallax)
	await process_frame
	var layers: Array[Parallax2D] = parallax.get_layers()
	assert(layers.size() == 5, "City Ruins must contain five independent Parallax2D layers")
	var expected_scales: Array[float] = [0.05, 0.15, 0.35, 0.65, 1.15]
	for index: int in layers.size():
		var layer: Parallax2D = layers[index]
		var sprite: Sprite2D = layer.get_child(0) as Sprite2D
		var expected_repeat: float = sprite.texture.get_width() * absf(sprite.scale.x)
		assert(is_equal_approx(layer.scroll_scale.x, expected_scales[index]))
		assert(layer.scroll_scale.y == 1.0)
		assert(is_equal_approx(layer.repeat_size.x, expected_repeat), "Repeat size must derive from scaled texture width")
		assert(layer.repeat_size.y == 0.0 and layer.repeat_times >= 3)
		assert(not layer.ignore_camera_scroll, "Parallax2D must follow Camera2D directly by default")
		assert(sprite.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST)
	parallax.set_scroll_progress(10000.0)
	assert(is_zero_approx(layers[0].scroll_offset.x), "Native camera mode must not introduce a competing manual offset")
	for layer: Parallax2D in layers:
		assert(layer.repeat_size.x > 640.0, "A repeated tile must cover the viewport without gaps")
	assert(not parallax.debug_parallax)
	var foreground_sprite: Sprite2D = layers[4].get_child(0) as Sprite2D
	assert(foreground_sprite.material is ShaderMaterial, "Foreground must mask its opaque sky area so combat stays readable")
	print("PASS: five camera-following Parallax2D layers, derived repetition, and depth speeds")
	quit(0)
