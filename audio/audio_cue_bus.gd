class_name AudioCueBus
extends Node

signal cue_played(cue: StringName)

const CUES: Array[StringName] = [&"deploy", &"wave_start", &"organ_activation", &"component_failure", &"boss_gate", &"boss_phase", &"victory", &"defeat", &"regeneration", &"level_up"]
const FREQUENCIES: Dictionary = {
	&"deploy": 330.0, &"wave_start": 440.0, &"organ_activation": 660.0,
	&"component_failure": 110.0, &"boss_gate": 147.0, &"boss_phase": 196.0,
	&"victory": 880.0, &"defeat": 82.0, &"regeneration": 523.0, &"level_up": 784.0
}
var player: AudioStreamPlayer


func _ready() -> void:
	player = AudioStreamPlayer.new()
	add_child(player)


func play(cue: StringName) -> void:
	if cue in CUES:
		cue_played.emit(cue)
		player.stream = _tone(FREQUENCIES.get(cue, 440.0), 0.12 if cue not in [&"victory", &"defeat"] else 0.28)
		player.play()


func _tone(frequency: float, duration: float) -> AudioStreamWAV:
	var rate: int = 22050
	var samples: int = int(rate * duration)
	var bytes := PackedByteArray()
	bytes.resize(samples * 2)
	for index: int in samples:
		var phase: float = fmod(float(index) * frequency / float(rate), 1.0)
		var envelope: float = 1.0 - float(index) / float(samples)
		var sample: int = int((1.0 if phase < 0.5 else -1.0) * 5000.0 * envelope)
		bytes.encode_s16(index * 2, sample)
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = rate
	stream.stereo = false
	stream.data = bytes
	return stream
