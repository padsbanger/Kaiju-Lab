class_name ScrollController
extends Node

signal progress_changed(progress: float)

@export var level_start_x: float = 0.0
@export var boss_gate_x: float = 42.0
@export var camera_forward_offset: float = 5.5
@export var far_parallax_factor: float = 0.82
@export var mid_parallax_factor: float = 0.55
@export var foreground_parallax_factor: float = 0.12
@export var follow_smoothing: float = 7.0
var tracked_kaiju: Kaiju
var camera: Camera3D
var far_layer: Node3D
var mid_layer: Node3D
var foreground_layer: Node3D
var progress: float = 0.0


func configure(specimen: Kaiju, battle_camera: Camera3D, far: Node3D, mid: Node3D, foreground: Node3D) -> void:
	tracked_kaiju = specimen
	camera = battle_camera
	far_layer = far
	mid_layer = mid
	foreground_layer = foreground
	_update_immediately()


func _process(delta: float) -> void:
	if tracked_kaiju == null or camera == null:
		return
	var target_x: float = maxf(level_start_x + camera_forward_offset, tracked_kaiju.global_position.x + camera_forward_offset)
	camera.global_position.x = lerpf(camera.global_position.x, target_x, minf(1.0, delta * follow_smoothing))
	_update_layers(camera.global_position.x)
	var next_progress: float = clampf((tracked_kaiju.global_position.x - level_start_x) / (boss_gate_x - level_start_x), 0.0, 1.0)
	if not is_equal_approx(progress, next_progress):
		progress = next_progress
		progress_changed.emit(progress)


func _update_immediately() -> void:
	if tracked_kaiju == null or camera == null:
		return
	camera.global_position.x = tracked_kaiju.global_position.x + camera_forward_offset
	_update_layers(camera.global_position.x)
	progress = clampf((tracked_kaiju.global_position.x - level_start_x) / (boss_gate_x - level_start_x), 0.0, 1.0)
	progress_changed.emit(progress)


func _update_layers(camera_x: float) -> void:
	if far_layer != null:
		far_layer.position.x = camera_x * far_parallax_factor
	if mid_layer != null:
		mid_layer.position.x = camera_x * mid_parallax_factor
	if foreground_layer != null:
		foreground_layer.position.x = camera_x * foreground_parallax_factor
