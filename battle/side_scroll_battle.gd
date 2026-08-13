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
var elapsed_seconds: float = 0.0
var active: bool = true


func _ready() -> void:
	camera.look_at(Vector3(camera.position.x, 1.5, 0.0))
	battle_controller.configure(kaiju, %BossGate.position.x)
	battle_controller.state_changed.connect(_on_state_changed)
	scroll_controller.boss_gate_x = %BossGate.position.x
	scroll_controller.configure(kaiju, camera, %FarLayer, %MidLayer, %ForegroundLayer)
	scroll_controller.progress_changed.connect(_on_progress_changed)
	status_changed.emit("DEPLOYMENT // CITY RUINS")


func _physics_process(delta: float) -> void:
	if not active:
		return
	elapsed_seconds += delta
	state_label.text = "AUTONOMY  %s   TARGET  %s" % [battle_controller.state_name(), _target_name()]


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


func build_result(outcome: BattleResult.Outcome) -> BattleResult:
	var result := BattleResult.new()
	result.outcome = outcome
	result.elapsed_seconds = elapsed_seconds
	result.map_progress = scroll_controller.progress
	result.capture_components(kaiju)
	return result
