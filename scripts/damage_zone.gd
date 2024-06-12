extends Area2D

@export var damage = 2.0
@export var knockback = 1000.0
@export var sound: AudioStreamPlayer2D = null
@export var aoe = true
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
const HEART_BREAK_FLOAT = preload("res://scenes/heart_break_float.tscn")
const HEART_BREAK_FLOOR = preload("res://scenes/heart_break_floor.tscn")

signal hit
var active = true



func _on_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if not active:
		return
	if (!body.has_method("_take_damage")):
		return
	if _check_parent(body):
		return
	var sound_override = body._take_damage(damage, knockback, global_position, 10)
	if not sound_override:
		_play_sound()
	
	if damage - int(damage) > 0:
		var heart_break_float = HEART_BREAK_FLOAT.instantiate()
		get_tree().current_scene.add_child(heart_break_float)
		heart_break_float.global_position = body.global_position
		heart_break_float.emit()
	if int(damage) > 0:
		var heart_break_floor = HEART_BREAK_FLOOR.instantiate()
		get_tree().current_scene.add_child(heart_break_floor)
		heart_break_floor.global_position = body.global_position
		heart_break_floor.set_amount(int(damage))
		heart_break_floor.emit()
	emit_signal("hit")
	if not aoe:
		active = false

func _check_parent(body):
	var current_node = self
	while current_node:
		if current_node == body:
			return true
		current_node = current_node.get_parent()
	return false

func _play_sound():
	if sound:
		sound.play()
	else:
		audio_stream_player_2d.play()
