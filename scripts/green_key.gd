extends AutoPickable

func auto_pickup(player):
	get_tree().current_scene.get_green_key()
	queue_free()
