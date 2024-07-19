extends Lootable

const FLYING_KEY = preload("res://scenes/flying_key.tscn")

func shoot():
	var flying_key = FLYING_KEY.instantiate()
	flying_key.global_position = get_parent().global_position
	flying_key.global_rotation = get_parent().global_rotation
	get_tree().current_scene.add_child(flying_key)
	queue_free()
	Tool.play_sound_2d(get_tree().current_scene, "res://sounds/weapon/dagger_woosh.mp3", flying_key.global_position)
