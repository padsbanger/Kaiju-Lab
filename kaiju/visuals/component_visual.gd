class_name ComponentVisual
extends Sprite3D

const PIXELS_PER_WORLD_UNIT: float = 420.0

@export var component_id: StringName


func _ready() -> void:
	pixel_size = 1.0 / PIXELS_PER_WORLD_UNIT
	billboard = BaseMaterial3D.BILLBOARD_ENABLED
	alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
	texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	no_depth_test = false
	shaded = false
