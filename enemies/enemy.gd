class_name BattleEnemy
extends CharacterBody2D

signal defeated(enemy: BattleEnemy, was_boss: bool)

@export var display_name: String = "Raider"
@export var max_health: float = 45.0
@export var move_speed: float = 34.0
@export var attack_damage: float = 8.0
@export var attack_range: float = 42.0
@export var attack_interval: float = 1.5
@export var ranged: bool = false
@export var is_boss: bool = false
@export var reward_value: int = 5

@onready var health_bar: ProgressBar = $HealthBar

var health: float
var target: KaijuBattleActor
var attack_timer: float = 0.0


func _ready() -> void:
	add_to_group("battle_enemies")
	collision_layer = 2
	collision_mask = 1
	health = max_health
	health_bar.max_value = max_health
	health_bar.value = health


func bind_target(value: KaijuBattleActor) -> void:
	target = value


func _physics_process(delta: float) -> void:
	if target == null or not is_instance_valid(target) or health <= 0.0:
		velocity = Vector2.ZERO
		return
	attack_timer = maxf(0.0, attack_timer - delta)
	var distance := global_position.distance_to(target.global_position)
	if distance > attack_range:
		velocity = Vector2(signf(target.global_position.x - global_position.x) * move_speed, 0.0)
		move_and_slide()
	else:
		velocity = Vector2.ZERO
		if attack_timer <= 0.0:
			_attack()
			attack_timer = attack_interval


func take_damage(amount: float) -> void:
	if health <= 0.0:
		return
	health = maxf(0.0, health - amount)
	health_bar.value = health
	modulate = Color(1.0, 0.45, 0.4)
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.12)
	if health <= 0.0:
		defeated.emit(self, is_boss)
		queue_free()


func threat_score() -> float:
	return (3.0 if ranged else 1.0) + (8.0 if is_boss else 0.0) + attack_damage * 0.05


func _attack() -> void:
	if target == null:
		return
	if ranged:
		var battle := get_parent()
		if battle.has_method("spawn_projectile"):
			battle.spawn_projectile(global_position + Vector2(-10.0, -12.0), target.global_position, attack_damage, false, display_name)
	else:
		target.receive_damage(attack_damage, display_name)

