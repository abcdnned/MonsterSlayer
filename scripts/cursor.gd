extends Node2D

func _ready():
	var cursor_texture = preload("res://sprites/cursor_v3.png")
	Input.set_custom_mouse_cursor(cursor_texture, Input.CURSOR_ARROW)
