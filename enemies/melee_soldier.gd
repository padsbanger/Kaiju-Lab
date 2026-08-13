class_name MeleeSoldier
extends CharacterBody2D

signal died(enemy: MeleeSoldier)

@export var speed: float = 70.0
@export var attack_distance: float = 68.0
@onready var health: Health = $Health
@onready var attack: MeleeAttack = $MeleeAttack
@onready var visual: Sprite2D = $Body
var target: Node2D


func _ready() -> void:
	add_to_group(&"enemies")
	health.died.connect(_on_died)


func _physics_process(delta: float) -> void:
	if health.is_dead:
		return
	if target == null or not is_instance_valid(target):
		target = get_tree().get_first_node_in_group(&"kaiju") as Node2D
		return
	var offset := Vector2(target.global_position.x - global_position.x, 0.0)
	_update_visual_facing(offset.x)
	if offset.length() > attack_distance:
		velocity = offset.normalized() * speed
	else:
		velocity = Vector2.ZERO
		attack.try_attack(target)
	velocity.y = 0.0
	move_and_slide()


func _update_visual_facing(horizontal_offset: float) -> void:
	# Source combat sprites face right. Flip the 2D art (not the 3D body) when
	# a target is to the left, as it is for standard right-edge wave entries.
	visual.flip_h = horizontal_offset < 0.0


func take_damage(amount: float, source: Node = null) -> void:
	health.take_damage(amount, source)


func _on_died(_source: Node) -> void:
	remove_from_group(&"enemies")
	died.emit(self)
	set_physics_process(false)
	queue_free()
