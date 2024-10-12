extends Lootable

@onready var audio_stream_player_2d = $AudioStreamPlayer2D

func shoot():
	p.heal(1.0)
	reparent(get_tree().current_scene, true)
	p = null
	visible = false
	audio_stream_player_2d.play()

func _on_timer_timeout():
	queue_free()
