extends Area2D

@export var damage = 2.0
@export var knockback = 1000.0
@export var sound: AudioStreamPlayer2D = null
@export var aoe = true
@export var stun = 10
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
const HEART_BREAK_FLOAT = preload("res://scenes/heart_break_float.tscn")
const HEART_BREAK_FLOOR = preload("res://scenes/heart_break_floor.tscn")

signal hit
var active = true



func _on_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	var tmp_d = damage
	if not active:
		return
	if (!body.has_method("_take_damage")):
		return
	if _check_parent(body):
		return
	var overrides = body._take_damage(damage, knockback, global_position, stun)
	if not overrides[0]:
		_play_sound()
	tmp_d = overrides[1]
	if tmp_d - int(tmp_d) > 0:
		var heart_break_float = HEART_BREAK_FLOAT.instantiate()
		get_tree().current_scene.add_child(heart_break_float)
		heart_break_float.global_position = body.global_position
		heart_break_float.emit()
	if int(tmp_d) > 0:
		var heart_break_floor = HEART_BREAK_FLOOR.instantiate()
		get_tree().current_scene.add_child(heart_break_floor)
		heart_break_floor.global_position = body.global_position
		heart_break_floor.set_amount(int(tmp_d))
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
