class_name RangedAttack
extends Node2D

signal projectile_fired

@export var projectile_scene: PackedScene
@export var damage: float = 14.0
@export var cooldown: float = 1.8
@export_flags_2d_physics var collision_targets: int = 1
var cooldown_remaining: float = 0.0


func _physics_process(delta: float) -> void:
	cooldown_remaining = maxf(0.0, cooldown_remaining - delta)


func try_attack(target: Node2D, source: Node) -> bool:
	if target == null or cooldown_remaining > 0.0 or projectile_scene == null:
		return false
	var projectile: CombatProjectile = projectile_scene.instantiate() as CombatProjectile
	var projectile_root: Node = get_tree().current_scene
	if projectile_root == null:
		projectile_root = get_tree().root
	projectile_root.add_child(projectile)
	projectile.damage = damage
	projectile.launch(global_position, target.global_position, source, collision_targets)
	cooldown_remaining = cooldown
	projectile_fired.emit()
	return true
