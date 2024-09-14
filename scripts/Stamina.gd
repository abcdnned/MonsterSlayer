extends TextureRect

func _on_player_stamina_change(stamina):
	size = Vector2(stamina * 2.0 * 64, 128.0)

