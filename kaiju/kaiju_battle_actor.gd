class_name KaijuBattleActor
extends CharacterBody2D

signal battle_state_changed(state: BattleState)
signal specimen_died

enum BattleState {
	ADVANCE,
	ENGAGE,
	RECOVER,
	STAGGERED,
	BOSS_FIGHT,
	DEAD,
}

const SOCKETS: PackedStringArray = ["torso", "arm_left", "arm_right", "heart", "stomach", "brain"]
const BASE_ADVANCE_SPEED: float = 54.0
const TARGET_SCAN_INTERVAL: float = 0.28

@onready var anatomy_areas: Node2D = $AnatomyAreas

var specimen: SpecimenState
var battle_state: BattleState = BattleState.ADVANCE
var target: BattleEnemy
var scan_timer: float = 0.0
var left_attack_timer: float = 0.0
var right_attack_timer: float = 0.0
var _damage_cursor: int = 0


func _ready() -> void:
	collision_layer = 1
	collision_mask = 2


func bind_specimen(value: SpecimenState) -> void:
	specimen = value
	for child: Node in anatomy_areas.get_children():
		if child is ComponentHitArea:
			(child as ComponentHitArea).bind_specimen(specimen)
	specimen.refresh_anatomy()


func _physics_process(delta: float) -> void:
	if specimen == null:
		return
	specimen.simulate(delta, battle_state == BattleState.ADVANCE)
	scan_timer -= delta
	left_attack_timer = maxf(0.0, left_attack_timer - delta)
	right_attack_timer = maxf(0.0, right_attack_timer - delta)
	if scan_timer <= 0.0:
		scan_timer = TARGET_SCAN_INTERVAL
		scan_for_target()
	_update_state()
	match battle_state:
		BattleState.ADVANCE:
			velocity = Vector2(BASE_ADVANCE_SPEED * specimen.movement_multiplier(), 0.0)
			move_and_slide()
		BattleState.ENGAGE, BattleState.BOSS_FIGHT:
			_engage_target()
		BattleState.RECOVER, BattleState.STAGGERED, BattleState.DEAD:
			velocity = Vector2.ZERO


func scan_for_target() -> void:
	target = null
	var best_score := -INF
	for node: Node in get_tree().get_nodes_in_group("battle_enemies"):
		if not node is BattleEnemy or not is_instance_valid(node):
			continue
		var enemy := node as BattleEnemy
		var distance := global_position.distance_to(enemy.global_position)
		if distance > 300.0:
			continue
		var score := 300.0 - distance
		var brain := specimen.components.get(&"brain") as ComponentState
		if brain != null and brain.definition.tags.has("defensive"):
			score += enemy.threat_score() * 20.0
		else:
			score += (100.0 - enemy.health) * 0.2
		if score > best_score:
			best_score = score
			target = enemy


func receive_damage(amount: float, cause: String) -> void:
	if specimen == null or battle_state == BattleState.DEAD:
		return
	var socket := StringName(SOCKETS[_damage_cursor % SOCKETS.size()])
	_damage_cursor += 1
	specimen.apply_damage(socket, amount * specimen.damage_multiplier(), cause)
	_update_state()


func _update_state() -> void:
	var next_state := battle_state
	var torso: ComponentState = specimen.components.get(&"torso")
	if torso == null or torso.is_destroyed():
		next_state = BattleState.DEAD
	elif not specimen.has_function(&"circulation") or specimen.blood < SpecimenState.CRITICAL_SUPPLY:
		next_state = BattleState.STAGGERED
	elif target != null and is_instance_valid(target):
		next_state = BattleState.BOSS_FIGHT if target.is_boss else BattleState.ENGAGE
	elif specimen.energy < 18.0 or specimen.heat > 72.0:
		next_state = BattleState.RECOVER
	else:
		next_state = BattleState.ADVANCE
	if next_state != battle_state:
		battle_state = next_state
		battle_state_changed.emit(battle_state)
		if battle_state == BattleState.DEAD:
			specimen_died.emit()


func _engage_target() -> void:
	if target == null or not is_instance_valid(target):
		return
	var distance := global_position.distance_to(target.global_position)
	var widest_range := _widest_attack_range()
	if distance > widest_range:
		velocity = Vector2(BASE_ADVANCE_SPEED * 0.65 * specimen.movement_multiplier(), 0.0)
		move_and_slide()
		return
	velocity = Vector2.ZERO
	_try_attack(&"arm_left", true)
	_try_attack(&"arm_right", false)


func _try_attack(socket: StringName, is_left: bool) -> void:
	var state: ComponentState = specimen.components.get(socket)
	if state == null or target == null or not is_instance_valid(target):
		return
	var cooldown := left_attack_timer if is_left else right_attack_timer
	if cooldown > 0.0 or global_position.distance_to(target.global_position) > state.definition.attack_range:
		return
	if not specimen.try_activate(socket):
		return
	var damage := state.definition.attack_power * specimen.attack_multiplier()
	if state.definition.attack_range > 100.0:
		var battle := get_parent()
		if battle.has_method("spawn_projectile"):
			battle.spawn_projectile(global_position + Vector2(26.0, -25.0), target.global_position, damage, true, state.definition.display_name)
	else:
		target.take_damage(damage)
	if is_left:
		left_attack_timer = state.definition.attack_cooldown
	else:
		right_attack_timer = state.definition.attack_cooldown


func _widest_attack_range() -> float:
	var result := 24.0
	for socket: StringName in [&"arm_left", &"arm_right"]:
		var state: ComponentState = specimen.components.get(socket)
		if state != null and state.offline_reason.is_empty():
			result = maxf(result, state.definition.attack_range)
	return result

