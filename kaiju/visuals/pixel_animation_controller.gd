class_name PixelAnimationController
extends Node

enum State { IDLE, WALK, ATTACK, HURT, DAMAGED, REGENERATING }

@export var torso_path: NodePath
@export var head_path: NodePath
@export var left_arm_path: NodePath
@export var right_arm_path: NodePath
var state: State = State.IDLE
var elapsed: float = 0.0
var base_positions: Dictionary[Node3D, Vector3] = {}


func _ready() -> void:
	for path: NodePath in [torso_path, head_path, left_arm_path, right_arm_path]:
		var node: Node3D = get_node_or_null(path) as Node3D
		if node != null:
			base_positions[node] = node.position


func _process(delta: float) -> void:
	elapsed += delta
	var step: float = floorf(elapsed * 8.0) / 8.0
	for node: Node3D in base_positions:
		node.position = base_positions[node]
	match state:
		State.IDLE:
			_offset(torso_path, Vector3.UP * (0.035 if int(step * 4.0) % 2 == 0 else 0.0))
		State.WALK:
			var stride: float = 0.07 if int(step * 8.0) % 2 == 0 else -0.04
			_offset(torso_path, Vector3.UP * absf(stride))
			_offset(left_arm_path, Vector3.UP * stride)
			_offset(right_arm_path, Vector3.DOWN * stride)
		State.ATTACK:
			_offset(right_arm_path, Vector3(0.18, 0.0, 0.0))
		State.HURT:
			_offset(torso_path, Vector3(-0.08, 0.0, 0.0))
		State.DAMAGED:
			_offset(head_path, Vector3.DOWN * 0.06)
		State.REGENERATING:
			_offset(torso_path, Vector3.UP * (0.08 if int(step * 6.0) % 2 == 0 else 0.0))


func set_state(next_state: State) -> void:
	state = next_state
	elapsed = 0.0


func _offset(path: NodePath, amount: Vector3) -> void:
	var node: Node3D = get_node_or_null(path) as Node3D
	if node != null:
		node.position += amount
