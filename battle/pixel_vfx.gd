class_name PixelVfx
extends Sprite3D

@export var lifetime: float = 0.35
@export var growth: float = 0.5


func _ready() -> void:
	texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	shaded = false
	billboard = BaseMaterial3D.BILLBOARD_DISABLED


func _process(delta: float) -> void:
	lifetime -= delta
	scale += Vector3.ONE * growth * delta
	modulate.a = clampf(lifetime * 3.0, 0.0, 1.0)
	if lifetime <= 0.0:
		queue_free()

