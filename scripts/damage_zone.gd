extends Area2D

@export var damage = 2.0
@export var knockback = 1000.0
@export var sound: AudioStreamPlayer2D = null
@onready var audio_stream_player_2d = $AudioStreamPlayer2D


func _on_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if (!body.has_method("_take_damage")):
		return
	if _check_parent(body):
		return
	body._take_damage(damage, knockback, global_position, 10)
	_play_sound()

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
