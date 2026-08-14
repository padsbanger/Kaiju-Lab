class_name SideScrollBattle
extends Node2D

signal battle_finished(result: BattleResult)

const DEFAULT_MAP: BattleMapData = preload("res://data/battles/city_ruins.tres")
const PROJECTILE_SCENE: PackedScene = preload("res://combat/projectile.tscn")

@onready var kaiju: KaijuBattleActor = $Kaiju
@onready var director: BattleDirector = $Director
@onready var world_color: ColorRect = $WorldColor
@onready var state_label: Label = $HUD/State
@onready var resource_label: Label = $HUD/Resources
@onready var progress_bar: ProgressBar = $HUD/Progress
@onready var wave_label: Label = $HUD/Wave

var specimen: SpecimenState
var map_data: BattleMapData
var resolved: bool = false
var elapsed_seconds: float = 0.0
var starting_health: Dictionary[StringName, float] = {}
var battle_speed: float = 1.0


func _ready() -> void:
	if specimen == null:
		var fresh := SpecimenState.new()
		fresh.initialize_default()
		bind_specimen(fresh)
	configure_map(DEFAULT_MAP)
	director.wave_spawned.connect(_on_wave_spawned)
	director.boss_defeated.connect(_resolve.bind(true))
	kaiju.specimen_died.connect(_resolve.bind(false))


func bind_specimen(value: SpecimenState) -> void:
	specimen = value
	starting_health.clear()
	for socket: StringName in specimen.components:
		starting_health[socket] = specimen.components[socket].health
	if is_node_ready():
		kaiju.bind_specimen(specimen)


func configure_map(value: BattleMapData) -> void:
	map_data = value
	world_color.color = map_data.sky_color
	progress_bar.max_value = map_data.length
	director.configure(map_data, kaiju, specimen.circuit_level if specimen != null else 1)
	wave_label.text = map_data.display_name + " // APPROACH"
	_apply_biome_palette()


func _process(delta: float) -> void:
	if resolved or specimen == null:
		return
	elapsed_seconds += delta
	director.update_progress(kaiju.position.x)
	progress_bar.value = kaiju.position.x
	state_label.text = "STATE  %s" % KaijuBattleActor.BattleState.keys()[kaiju.battle_state]
	resource_label.text = "E %03d  B %03d  O %03d  H %03d" % [specimen.energy, specimen.blood, specimen.oxygen, specimen.heat]


func spawn_projectile(start: Vector2, target_position: Vector2, damage: float, from_kaiju: bool, cause: String) -> CombatProjectile:
	var projectile := PROJECTILE_SCENE.instantiate() as CombatProjectile
	add_child(projectile)
	projectile.process_mode = Node.PROCESS_MODE_PAUSABLE
	projectile.configure(start, target_position, damage, from_kaiju, cause)
	return projectile


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		get_tree().paused = not get_tree().paused
		state_label.text = "PAUSED" if get_tree().paused else "STATE  %s" % KaijuBattleActor.BattleState.keys()[kaiju.battle_state]
	elif event.is_action_pressed("speed_up"):
		battle_speed = 2.0 if battle_speed < 2.0 else 1.0
		Engine.time_scale = battle_speed
		wave_label.text = "%s // %.0fX" % [map_data.display_name, battle_speed]


func _on_wave_spawned(index: int) -> void:
	var wave := map_data.waves[index]
	wave_label.text = "%s // %s" % [map_data.display_name, String(wave.wave_id).to_upper()]


func _resolve(victory: bool) -> void:
	if resolved:
		return
	resolved = true
	state_label.text = "VICTORY" if victory else "SPECIMEN DOWN"
	var result := BattleResult.new()
	result.victory = victory
	result.map_id = map_data.map_id
	result.progress = clampf(kaiju.position.x / map_data.length, 0.0, 1.0)
	result.enemies_defeated = director.defeated_count
	result.waves_reached = director.next_wave_index
	result.elapsed_seconds = elapsed_seconds
	var threat := specimen.circuit_level if specimen != null else 1
	result.biomass_reward = roundi((director.defeated_count * 3 + (20 if victory else 4)) * (1.0 + (threat - 1) * 0.15))
	result.dna_reward = 2 + (3 if victory else 0)
	result.experience_reward = director.defeated_count * 8 + (45 if victory else 10)
	for socket: StringName in specimen.components:
		var lost := maxf(0.0, starting_health.get(socket, specimen.components[socket].health) - specimen.components[socket].health)
		if lost > 0.0:
			result.component_damage[String(socket)] = {
				"lost": lost,
				"cause": specimen.components[socket].damage_cause,
			}
	battle_finished.emit(result)


func _apply_biome_palette() -> void:
	var layers: Array[Node] = [$FarSkyline, $RuinsBack, $RuinsMid, $NearDebris, $Foreground]
	for index: int in range(layers.size()):
		var strip := layers[index].get_node("Strip") as ParallaxStrip
		if index < map_data.layer_colors.size():
			strip.strip_color = map_data.layer_colors[index]
			strip.detail_color = map_data.layer_colors[index].lightened(0.28)
		strip.queue_redraw()


func _exit_tree() -> void:
	Engine.time_scale = 1.0
	if get_tree() != null:
		get_tree().paused = false
