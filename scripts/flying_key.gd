extends Node2D

@onready var area_2d = $Area2D

const SPEED = 2000.0

func _ready():
	pass # Replace with function body.

func _process(delta):
	position += Vector2(cos(rotation), sin(rotation)) * SPEED * delta


func _on_timer_timeout():
	var key = load("res://scenes/i_start_key.tscn").instantiate()
	key.global_position = global_position
	key.lootable = true
	get_tree().current_scene.add_child(key)
	queue_free()


func _on_area_2d_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	if (area.get_parent().has_method("open_gate")):
		area.get_parent().open_gate()
	else:
		var key = load("res://scenes/i_start_key.tscn").instantiate()
		key.global_position = global_position
		get_tree().current_scene.add_child(key)
	queue_free()
