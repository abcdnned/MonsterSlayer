extends TextureRect

func _on_player_health_change(health):
	size = Vector2(health * 2.0 * 64, 128.0)

