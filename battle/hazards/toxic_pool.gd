class_name ToxicPool
extends Area2D

@export var damage_per_tick: float = 4.0
@export var tick_interval: float = 0.8
@export var heat_per_tick: float = 5.0
var _remaining: float = 0.0


func _physics_process(delta: float) -> void:
	_remaining -= delta
	if _remaining > 0.0:
		return
	_remaining = tick_interval
	for body: Node2D in get_overlapping_bodies():
		if body is Kaiju:
			(body as Kaiju).take_damage(damage_per_tick, self)
			(body as Kaiju).resource_controller.heat = minf(100.0, (body as Kaiju).resource_controller.heat + heat_per_tick)
