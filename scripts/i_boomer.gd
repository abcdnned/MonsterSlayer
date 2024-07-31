extends Lootable

var missle_type: String = "res://scenes/flying_boomer.tscn"

func shoot():
	var missle = load(missle_type).instantiate()
	missle.dis = get_global_mouse_position().distance_to(get_tree().current_scene.player.global_position)
	missle.global_position = get_parent().global_position
	missle.global_rotation = get_parent().global_rotation
	get_tree().current_scene.add_child(missle)
	queue_free()
	Tool.play_sound_2d(get_tree().current_scene, "res://sounds/weapon/dagger_woosh.mp3", missle.global_position)
