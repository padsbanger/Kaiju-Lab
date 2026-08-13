class_name ComponentVisual
extends Sprite2D

@export var component_id: StringName


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
