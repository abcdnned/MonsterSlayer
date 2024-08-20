extends Lootable

@onready var audio_stream_player_2d = $AudioStreamPlayer2D

func shoot():
	p.increase_max_health(1)
	reparent(get_tree().current_scene, true)
	p = null
	visible = false
	audio_stream_player_2d.play()
