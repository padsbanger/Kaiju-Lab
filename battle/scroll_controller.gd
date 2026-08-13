class_name ScrollController
extends Node

signal progress_changed(progress: float)

@export var level_start_x: float = 80.0
@export var boss_gate_x: float = 4880.0
@export var kaiju_screen_x: float = 0.25
@export var follow_smoothing: float = 8.0
var tracked_kaiju: Kaiju
var camera: Camera2D
var progress: float = 0.0


func configure(specimen: Kaiju, battle_camera: Camera2D) -> void:
	tracked_kaiju = specimen
	camera = battle_camera
	_update_immediately()


func _process(delta: float) -> void:
	if tracked_kaiju == null or camera == null:
		return
	var viewport_width: float = get_viewport().get_visible_rect().size.x
	var forward_offset: float = viewport_width * (0.5 - kaiju_screen_x)
	var target_x: float = maxf(level_start_x + forward_offset, tracked_kaiju.global_position.x + forward_offset)
	camera.global_position.x = roundf(lerpf(camera.global_position.x, target_x, minf(1.0, delta * follow_smoothing)))
	var next_progress: float = clampf((tracked_kaiju.global_position.x - level_start_x) / (boss_gate_x - level_start_x), 0.0, 1.0)
	if not is_equal_approx(progress, next_progress):
		progress = next_progress
		progress_changed.emit(progress)


func _update_immediately() -> void:
	if tracked_kaiju == null or camera == null:
		return
	var viewport_width: float = get_viewport().get_visible_rect().size.x
	var forward_offset: float = viewport_width * (0.5 - kaiju_screen_x)
	camera.global_position.x = roundf(tracked_kaiju.global_position.x + forward_offset)
	progress = clampf((tracked_kaiju.global_position.x - level_start_x) / (boss_gate_x - level_start_x), 0.0, 1.0)
	progress_changed.emit(progress)
