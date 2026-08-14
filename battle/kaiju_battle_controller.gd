class_name KaijuBattleController
extends Node

signal state_changed(state: State)

enum State { ADVANCE, ENGAGE, RECOVER, STAGGERED, BOSS_FIGHT, DEAD }

@export var advance_speed: float = 32.0
@export var acceleration: float = 70.0
@export var deceleration: float = 150.0
@export var engagement_range: float = 300.0
@export var blocking_range: float = 105.0
@export var lane_tolerance: float = 140.0
var kaiju: Kaiju
var boss_gate_x: float = 4880.0
var state: State = State.ADVANCE
var forced_target: Node2D
var recover_remaining: float = 0.0


func configure(specimen: Kaiju, gate_x: float) -> void:
	kaiju = specimen
	boss_gate_x = gate_x
	kaiju.set_physics_process(false)
	kaiju.brain_controller.set_physics_process(true)
	kaiju.died.connect(func(_source: Node) -> void: set_state(State.DEAD))


func _physics_process(delta: float) -> void:
	if kaiju == null or state == State.DEAD:
		return
	var target: Node2D = forced_target if is_instance_valid(forced_target) else kaiju.brain_controller.target
	if target != null and _is_relevant(target):
		set_state(State.BOSS_FIGHT if target.is_in_group(&"boss") else State.ENGAGE)
		_engage(target, delta)
	elif recover_remaining > 0.0:
		recover_remaining -= delta
		set_state(State.RECOVER)
		_move_toward_speed(0.35, delta)
	else:
		set_state(State.ADVANCE)
		_move_toward_speed(advance_speed, delta)
	kaiju.velocity.y = 0.0
	kaiju.move_and_slide()
	kaiju.pixel_animation.set_state(PixelAnimationController.State.WALK if absf(kaiju.velocity.x) > 0.08 else PixelAnimationController.State.IDLE)


func _is_relevant(target: Node2D) -> bool:
	var offset: Vector2 = target.global_position - kaiju.global_position
	return absf(offset.x) <= engagement_range and absf(offset.y) <= lane_tolerance


func _engage(target: Node2D, delta: float) -> void:
	var distance: float = kaiju.global_position.distance_to(target.global_position)
	_move_toward_speed(0.0 if distance <= blocking_range else advance_speed * 0.35, delta)
	var melee_component: KaijuComponent = kaiju.anatomy_controller.get_component(&"claw_left")
	if distance <= blocking_range and kaiju.anatomy_controller.is_component_operational(melee_component):
		if kaiju.claw_attack.try_attack(target):
			kaiju.pixel_animation.set_state(PixelAnimationController.State.ATTACK)
	elif distance <= engagement_range:
		kaiju.spit_attack.try_attack(target, kaiju)
	if not is_instance_valid(target):
		recover_remaining = 0.5


func _move_toward_speed(desired: float, delta: float) -> void:
	var rate: float = acceleration if desired > kaiju.velocity.x else deceleration
	var supplied_desired: float = desired * kaiju.loadout_movement_multiplier * kaiju.resource_controller.movement_factor()
	kaiju.velocity.x = move_toward(kaiju.velocity.x, supplied_desired, rate * delta)
	kaiju.resource_controller.set_movement_load(absf(kaiju.velocity.x) / maxf(1.0, advance_speed))
	if kaiju.global_position.x >= boss_gate_x and state != State.BOSS_FIGHT:
		kaiju.velocity.x = 0.0


func stagger(duration: float = 0.7) -> void:
	recover_remaining = maxf(duration, 0.0)
	set_state(State.STAGGERED)
	if kaiju != null:
		kaiju.velocity = Vector2.ZERO


func set_state(next_state: State) -> void:
	if state == next_state:
		return
	state = next_state
	state_changed.emit(state)


func state_name() -> String:
	return State.keys()[state]
