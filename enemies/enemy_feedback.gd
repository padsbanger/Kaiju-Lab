class_name EnemyFeedback
extends Node2D

var health: Health
var bar: ProgressBar
var telegraph: Label


func bind(owner_health: Health) -> void:
	health = owner_health
	bar = ProgressBar.new()
	bar.position = Vector2(-28, -78)
	bar.size = Vector2(56, 5)
	bar.show_percentage = false
	bar.max_value = owner_health.max_health
	bar.value = owner_health.current_health
	bar.z_index = 30
	add_child(bar)
	telegraph = Label.new()
	telegraph.position = Vector2(-34, -94)
	telegraph.size = Vector2(68, 14)
	telegraph.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	telegraph.add_theme_font_size_override("font_size", 7)
	telegraph.add_theme_color_override("font_color", Color(1.0, 0.72, 0.28))
	telegraph.visible = false
	telegraph.z_index = 30
	add_child(telegraph)
	health.health_changed.connect(_on_health_changed)


func telegraph_action(label: String, duration: float = 0.35) -> void:
	if telegraph == null:
		return
	telegraph.text = label
	telegraph.visible = true
	var tween: Tween = create_tween()
	tween.tween_interval(duration)
	tween.tween_callback(func() -> void: if is_instance_valid(telegraph): telegraph.visible = false)


func _on_health_changed(current: float, maximum: float) -> void:
	if bar != null:
		bar.max_value = maximum
		bar.value = current
