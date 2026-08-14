class_name ParallaxStrip
extends Node2D

@export var strip_color: Color = Color(0.1, 0.2, 0.25)
@export var detail_color: Color = Color(0.18, 0.3, 0.32)
@export var horizon_y: float = 160.0
@export var block_width: float = 72.0
@export var block_height: float = 48.0


func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(0.0, horizon_y, 640.0, 360.0 - horizon_y), strip_color)
	var count := ceili(640.0 / block_width) + 1
	for index: int in range(count):
		var x := index * block_width
		var variation := float((index * 19) % 31)
		draw_rect(Rect2(x + 4.0, horizon_y - block_height - variation, block_width - 12.0, block_height + variation), detail_color)
		draw_rect(Rect2(x + 14.0, horizon_y - 18.0 - variation, 6.0, 7.0), strip_color.lightened(0.2))

