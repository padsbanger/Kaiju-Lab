class_name SideScrollBattle
extends Node3D

signal battle_finished(result: BattleResult)
signal status_changed(message: String)

@export var level_length: float = 48.0
@export var prototype_advance_speed: float = 1.1
@onready var kaiju: Kaiju = %Kaiju
@onready var camera: Camera3D = %BattleCamera
@onready var scroll_controller: ScrollController = $ScrollController
@onready var progress_bar: ProgressBar = %ProgressBar
@onready var progress_label: Label = %ProgressLabel
var elapsed_seconds: float = 0.0
var active: bool = true


func _ready() -> void:
	kaiju.brain_controller.set_physics_process(false)
	kaiju.set_physics_process(false)
	camera.look_at(Vector3(camera.position.x, 1.5, 0.0))
	scroll_controller.boss_gate_x = %BossGate.position.x
	scroll_controller.configure(kaiju, camera, %FarLayer, %MidLayer, %ForegroundLayer)
	scroll_controller.progress_changed.connect(_on_progress_changed)
	status_changed.emit("DEPLOYMENT // CITY RUINS")


func _physics_process(delta: float) -> void:
	if not active:
		return
	elapsed_seconds += delta
	kaiju.global_position.x = minf(%BossGate.global_position.x, kaiju.global_position.x + prototype_advance_speed * delta)
	kaiju.pixel_animation.set_state(PixelAnimationController.State.WALK)


func bind_specimen(specimen: SpecimenState) -> void:
	specimen.apply_to_kaiju(kaiju)


func _on_progress_changed(progress: float) -> void:
	progress_bar.value = progress * 100.0
	progress_label.text = "CITY RUINS  %d%%  >>>  BOSS GATE" % int(progress * 100.0)


func build_result(outcome: BattleResult.Outcome) -> BattleResult:
	var result := BattleResult.new()
	result.outcome = outcome
	result.elapsed_seconds = elapsed_seconds
	result.map_progress = scroll_controller.progress
	result.capture_components(kaiju)
	return result
