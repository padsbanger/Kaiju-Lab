class_name ComponentVisual
extends Sprite3D

const PIXELS_PER_WORLD_UNIT: float = 48.0

@export var component_id: StringName


func _ready() -> void:
	pixel_size = 1.0 / PIXELS_PER_WORLD_UNIT
	billboard = BaseMaterial3D.BILLBOARD_DISABLED
	alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
	texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	no_depth_test = false
	shaded = false
