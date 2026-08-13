class_name Kaiju
extends CharacterBody3D

@onready var component_root: Node3D = %ComponentRoot
@onready var head_socket: Node3D = %HeadSocket
@onready var left_arm_socket: Node3D = %LeftArmSocket
@onready var right_arm_socket: Node3D = %RightArmSocket


func _ready() -> void:
	assert(component_root != null, "Kaiju requires a component root")
	assert(head_socket != null, "Kaiju requires a head socket")
	assert(left_arm_socket != null, "Kaiju requires a left arm socket")
	assert(right_arm_socket != null, "Kaiju requires a right arm socket")
