extends TextureRect

func _on_player_max_stamina_change(max_stamina):
	size = Vector2(max_stamina * 128.0, 128.0)

