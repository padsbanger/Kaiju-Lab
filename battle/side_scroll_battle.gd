class_name SideScrollBattle
extends Node3D

signal battle_finished(result: BattleResult)
signal status_changed(message: String)

@export var level_length: float = 48.0
@onready var kaiju: Kaiju = %Kaiju
@onready var camera: Camera3D = %BattleCamera
@onready var scroll_controller: ScrollController = $ScrollController
@onready var battle_controller: KaijuBattleController = $KaijuBattleController
@onready var progress_bar: ProgressBar = %ProgressBar
@onready var progress_label: Label = %ProgressLabel
@onready var state_label: Label = %StateLabel
@onready var wave_label: Label = %WaveLabel
@onready var enemy_root: Node3D = %EnemyRoot
@onready var battle_director: BattleDirector = $BattleDirector
var elapsed_seconds: float = 0.0
var active: bool = true
var resolved: bool = false
var boss: Node3D


func _ready() -> void:
	camera.look_at(Vector3(camera.position.x, 1.5, 0.0))
	battle_controller.configure(kaiju, %BossGate.position.x)
	battle_controller.state_changed.connect(_on_state_changed)
	scroll_controller.boss_gate_x = %BossGate.position.x
	scroll_controller.configure(kaiju, camera, %FarLayer, %MidLayer, %ForegroundLayer)
	scroll_controller.progress_changed.connect(_on_progress_changed)
	battle_director.configure(self)
	battle_director.phase_changed.connect(_on_phase_changed)
	battle_director.boss_spawned.connect(_on_boss_spawned)
	kaiju.died.connect(_on_kaiju_died)
	status_changed.emit("DEPLOYMENT // CITY RUINS")


func _physics_process(delta: float) -> void:
	if not active:
		return
	elapsed_seconds += delta
	state_label.text = "AUTONOMY  %s   TARGET  %s" % [battle_controller.state_name(), _target_name()]
	wave_label.text = "%s   HOSTILES %02d   %02d:%02d" % [battle_director.phase_name(), battle_director.remaining_count(), int(elapsed_seconds) / 60, int(elapsed_seconds) % 60]


func bind_specimen(specimen: SpecimenState) -> void:
	specimen.apply_to_kaiju(kaiju)


func _on_progress_changed(progress: float) -> void:
	progress_bar.value = progress * 100.0
	progress_label.text = "CITY RUINS  %d%%  >>>  BOSS GATE" % int(progress * 100.0)


func _on_state_changed(_state: KaijuBattleController.State) -> void:
	state_label.text = "AUTONOMY  %s   TARGET  %s" % [battle_controller.state_name(), _target_name()]


func _target_name() -> String:
	var target: Node3D = kaiju.brain_controller.target
	return target.name.to_upper() if is_instance_valid(target) else "NONE"


func _on_phase_changed(_phase: BattleDirector.Phase, title: String) -> void:
	wave_label.text = title


func build_result(outcome: BattleResult.Outcome) -> BattleResult:
	var result := BattleResult.new()
	result.outcome = outcome
	result.elapsed_seconds = elapsed_seconds
	result.map_progress = scroll_controller.progress
	result.capture_components(kaiju)
	result.waves_survived = battle_director.waves_cleared
	result.enemies_defeated = battle_director.enemies_defeated
	result.boss_defeated = outcome == BattleResult.Outcome.BOSS_DEFEATED
	result.experience_reward = battle_director.enemies_defeated * 12 + (100 if result.boss_defeated else 0)
	result.biomass_reward = battle_director.enemies_defeated * 3 + (40 if result.boss_defeated else 0)
	result.dna_reward = 20 if result.boss_defeated else 4 * battle_director.waves_cleared
	return result


func _on_boss_spawned(spawned_boss: Node3D) -> void:
	boss = spawned_boss
	battle_controller.forced_target = boss
	boss.died.connect(_on_boss_died, CONNECT_ONE_SHOT)
	%BossBar.visible = true
	boss.health.health_changed.connect(func(current: float, maximum: float) -> void: %BossBar.value = 100.0 * current / maximum)


func _on_boss_died(_enemy: Node3D) -> void:
	resolve_battle(BattleResult.Outcome.BOSS_DEFEATED)


func _on_kaiju_died(_source: Node) -> void:
	resolve_battle(BattleResult.Outcome.KAIJU_DEAD, "Specimen vital systems failed")


func resolve_battle(outcome: BattleResult.Outcome, reason: String = "") -> void:
	if resolved:
		return
	resolved = true
	active = false
	battle_controller.set_physics_process(false)
	var result: BattleResult = build_result(outcome)
	result.failure_reason = reason
	%ResultPanel.visible = true
	%ResultLabel.text = _result_summary(result)
	await get_tree().create_timer(0.35).timeout
	battle_finished.emit(result)


func _result_summary(result: BattleResult) -> String:
	var title: String = "DEPLOYMENT COMPLETE" if result.boss_defeated else "SPECIMEN RECALLED"
	return "%s\nPROGRESS %d%%  TIME %02d:%02d\nHOSTILES %d  WAVES %d\nREWARD +%d XP  +%d BIOMASS  +%d DNA\n%s" % [title, int(result.map_progress * 100.0), int(result.elapsed_seconds) / 60, int(result.elapsed_seconds) % 60, result.enemies_defeated, result.waves_survived, result.experience_reward, result.biomass_reward, result.dna_reward, result.failure_reason]
