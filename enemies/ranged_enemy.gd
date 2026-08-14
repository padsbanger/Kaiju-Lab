class_name RangedEnemy
extends CharacterBody2D

const ENEMY_FEEDBACK: Script = preload("res://enemies/enemy_feedback.gd")

signal died(enemy: RangedEnemy)

@export var speed: float = 58.0
@export var preferred_distance: float = 230.0
@export var unit_name: String = "RANGED SOLDIER"
@onready var health: Health = $Health
@onready var attack: RangedAttack = $RangedAttack
@onready var visual: Sprite2D = get_node_or_null("Body") as Sprite2D
var target: Node2D
var base_y: float
var hover_elapsed: float = 0.0
var feedback: Node2D


func _ready() -> void:
	add_to_group(&"enemies")
	health.died.connect(_on_died)
	base_y = global_position.y
	if visual == null:
		visual = get_node_or_null("Sprite") as Sprite2D
	assert(visual != null, "%s requires a Sprite2D visual named Body or Sprite" % name)
	feedback = ENEMY_FEEDBACK.new() as Node2D
	add_child(feedback)
	feedback.bind(health)
	attack.projectile_fired.connect(func() -> void: feedback.telegraph_action("FIRE" if unit_name != "SPORE MOTE" else "SPORE"))


func _physics_process(delta: float) -> void:
	if target == null or not is_instance_valid(target):
		target = get_tree().get_first_node_in_group(&"kaiju") as Node2D
		return
	var offset := Vector2(target.global_position.x - global_position.x, 0.0)
	if unit_name == "SPORE MOTE":
		hover_elapsed += delta
		global_position.y = base_y + roundf(sin(hover_elapsed * 2.7) * 12.0)
	_update_visual_facing(offset.x)
	if offset.length() > preferred_distance + 20.0:
		velocity = offset.normalized() * speed
	elif offset.length() < preferred_distance - 35.0:
		velocity = -offset.normalized() * speed * 0.65
	else:
		velocity = Vector2.ZERO
	attack.try_attack(target, self)
	velocity.y = 0.0
	move_and_slide()


func _update_visual_facing(horizontal_offset: float) -> void:
	# Source art faces right; standard right-edge spawns face the kaiju to the left.
	visual.flip_h = horizontal_offset < 0.0


func take_damage(amount: float, source: Node = null) -> void:
	health.take_damage(amount, source)


func _on_died(_source: Node) -> void:
	remove_from_group(&"enemies")
	died.emit(self)
	queue_free()
