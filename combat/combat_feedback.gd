class_name CombatFeedback
extends Node3D

var specimen: Kaiju
var attack_player: AudioStreamPlayer
var failure_player: AudioStreamPlayer


func _ready() -> void:
	attack_player = AudioStreamPlayer.new()
	failure_player = AudioStreamPlayer.new()
	add_child(attack_player)
	add_child(failure_player)
	attack_player.stream = _make_tone(150.0, 0.08, 0.18)
	failure_player.stream = _make_tone(72.0, 0.28, 0.28)


func bind(kaiju: Kaiju) -> void:
	specimen = kaiju
	kaiju.claw_attack.attack_started.connect(_on_attack)
	kaiju.spit_attack.projectile_fired.connect(_on_attack)
	kaiju.anatomy_controller.component_destroyed.connect(_on_component_destroyed)


func _on_attack() -> void:
	attack_player.play()
	_spawn_pulse(Color(0.25, 1.0, 0.38, 1.0), 1.8)
	var left_visual: Sprite3D = specimen.get_node("ComponentRoot/LeftArmSocket/ClawComponent/Visual") as Sprite3D
	var tween: Tween = create_tween()
	tween.tween_property(left_visual, "scale", Vector3.ONE * 0.88, 0.06)
	tween.tween_property(left_visual, "scale", Vector3.ONE * 0.78, 0.12)


func _on_component_destroyed(_component: KaijuComponent) -> void:
	failure_player.play()
	_spawn_pulse(Color(0.85, 0.1, 0.28, 1.0), 4.2)


func _spawn_pulse(color: Color, energy: float) -> void:
	if specimen == null:
		return
	var pulse := OmniLight3D.new()
	pulse.light_color = color
	pulse.light_energy = energy
	pulse.omni_range = 4.0
	pulse.position = specimen.global_position + Vector3.UP * 1.5
	add_child(pulse)
	var tween: Tween = create_tween()
	tween.tween_property(pulse, "light_energy", 0.0, 0.22)
	tween.tween_callback(pulse.queue_free)


func _make_tone(frequency: float, duration: float, volume: float) -> AudioStreamWAV:
	const MIX_RATE: int = 22050
	var frame_count: int = int(MIX_RATE * duration)
	var bytes := PackedByteArray()
	bytes.resize(frame_count * 2)
	for frame: int in frame_count:
		var envelope: float = 1.0 - float(frame) / float(frame_count)
		var sample: float = sin(TAU * frequency * float(frame) / float(MIX_RATE)) * envelope * volume
		bytes.encode_s16(frame * 2, int(clampf(sample, -1.0, 1.0) * 32767.0))
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = MIX_RATE
	stream.stereo = false
	stream.data = bytes
	return stream
