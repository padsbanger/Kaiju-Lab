class_name CombatProjectile
extends Area2D

var direction: Vector2 = Vector2.RIGHT
var speed: float = 240.0
var damage: float = 10.0
var from_kaiju: bool = true
var cause: String = "projectile"
var lifetime: float = 3.0


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func configure(start: Vector2, target: Vector2, amount: float, launched_by_kaiju: bool, damage_cause: String) -> void:
	global_position = start
	direction = start.direction_to(target)
	damage = amount
	from_kaiju = launched_by_kaiju
	cause = damage_cause
	collision_layer = 0
	collision_mask = 2 if from_kaiju else 1


func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if from_kaiju and body.has_method("take_damage"):
		body.take_damage(damage)
		queue_free()
	elif not from_kaiju and body.has_method("receive_damage"):
		body.receive_damage(damage, cause)
		queue_free()

