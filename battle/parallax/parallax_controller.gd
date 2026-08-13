class_name PixelParallaxController
extends Node2D

@export var debug_parallax: bool = false
@export var pixel_snap: bool = true
@export var manual_scroll: bool = false
var _layers: Array[Parallax2D] = []
var _debug_label: Label


func _ready() -> void:
	_collect_and_configure_layers()
	_setup_debug_overlay()
	set_process(debug_parallax)


func _process(_delta: float) -> void:
	if debug_parallax:
		_refresh_debug_text()


func set_scroll_progress(world_x: float) -> void:
	if not manual_scroll:
		return
	for layer: Parallax2D in _layers:
		# Parallax2D applies scroll_scale to scroll_offset internally. Quantize
		# the resulting screen movement, then convert it back to its raw offset.
		var offset_x: float = -world_x
		if pixel_snap and not is_zero_approx(layer.scroll_scale.x):
			offset_x = roundf(offset_x * layer.scroll_scale.x) / layer.scroll_scale.x
		layer.scroll_offset = Vector2(offset_x, 0.0)
	if debug_parallax:
		_refresh_debug_text()


func add_scroll(delta_world_x: float) -> void:
	if not manual_scroll:
		return
	for layer: Parallax2D in _layers:
		var delta_pixels: float = -delta_world_x
		var next_x: float = layer.scroll_offset.x + delta_pixels
		if pixel_snap and not is_zero_approx(layer.scroll_scale.x):
			next_x = roundf(next_x * layer.scroll_scale.x) / layer.scroll_scale.x
		layer.scroll_offset.x = next_x
	if debug_parallax:
		_refresh_debug_text()


func get_layers() -> Array[Parallax2D]:
	return _layers.duplicate()


func _collect_and_configure_layers() -> void:
	_layers.clear()
	for node: Node in find_children("*", "Parallax2D", true, false):
		var layer: Parallax2D = node as Parallax2D
		var sprite: Sprite2D = _find_layer_sprite(layer)
		if sprite == null or sprite.texture == null:
			push_warning("Parallax layer %s has no textured Sprite2D" % layer.name)
			continue
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		var scaled_width: float = sprite.texture.get_width() * absf(sprite.scale.x)
		layer.repeat_size = Vector2(roundf(scaled_width), 0.0)
		layer.repeat_times = 3
		layer.ignore_camera_scroll = manual_scroll
		_layers.append(layer)
		var marker: ColorRect = layer.get_node_or_null("RepeatBoundary") as ColorRect
		if marker != null:
			marker.position.x = layer.repeat_size.x
			marker.visible = debug_parallax


func _find_layer_sprite(layer: Parallax2D) -> Sprite2D:
	for child: Node in layer.get_children():
		if child is Sprite2D:
			return child as Sprite2D
	return null


func _setup_debug_overlay() -> void:
	var debug_canvas: CanvasLayer = get_node_or_null("DebugCanvas") as CanvasLayer
	if debug_canvas == null:
		return
	debug_canvas.visible = debug_parallax
	_debug_label = debug_canvas.get_node_or_null("DebugLabel") as Label
	if debug_parallax:
		_refresh_debug_text()


func _refresh_debug_text() -> void:
	if _debug_label == null:
		return
	var lines: Array[String] = ["PIXEL PARALLAX DEBUG"]
	for layer: Parallax2D in _layers:
		var sprite: Sprite2D = _find_layer_sprite(layer)
		lines.append("%s  scale=%.2f  repeat=%d  offset=%d  texture=%dx%d" % [
			layer.name,
			layer.scroll_scale.x,
			int(layer.repeat_size.x),
			int(layer.scroll_offset.x),
			sprite.texture.get_width(),
			sprite.texture.get_height()
		])
	_debug_label.text = "\n".join(lines)
