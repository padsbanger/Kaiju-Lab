class_name CitadelBoss
extends CharacterBody3D

signal died(enemy: CitadelBoss)
signal pressure_used(pressure: StringName)

@onready var health: Health = $Health
@onready var attack: RangedAttack = $SiegeCannon
var target: Kaiju
var stomp_remaining: float = 2.5
var cannon_remaining: float = 0.8


func _ready() -> void:
	add_to_group(&"enemies")
	add_to_group(&"boss")
	health.died.connect(_on_died)
	target = get_tree().get_first_node_in_group(&"kaiju") as Kaiju


func _physics_process(delta: float) -> void:
	if health.is_dead:
		return
	if target == null or not is_instance_valid(target):
		target = get_tree().get_first_node_in_group(&"kaiju") as Kaiju
		return
	cannon_remaining -= delta
	stomp_remaining -= delta
	if cannon_remaining <= 0.0:
		attack.try_attack(target, self)
		cannon_remaining = 2.2
		pressure_used.emit(&"circulation_siege")
	if stomp_remaining <= 0.0 and global_position.distance_to(target.global_position) < 5.0:
		target.take_damage(8.0, self)
		var damaged: Array[KaijuComponent] = target.anatomy_controller.get_damaged_components()
		if not damaged.is_empty():
			damaged[0].take_damage(7.0, self)
		stomp_remaining = 3.8
		pressure_used.emit(&"structural_shock")


func take_damage(amount: float, source: Node = null) -> void:
	health.take_damage(amount, source)


func _on_died(_source: Node) -> void:
	remove_from_group(&"enemies")
	died.emit(self)
	set_physics_process(false)
	queue_free()

