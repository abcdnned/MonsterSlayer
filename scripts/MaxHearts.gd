extends TextureRect

func _on_player_max_health_change(max_health):
	size = Vector2(max_health * 128.0, 128.0)

