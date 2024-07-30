extends Lootable

var missle_type: String = "res://scenes/i_boomer.tscn"

func shoot():
	var missle = load(missle_type).instantiate()
	missle.target_position = get_global_mouse_position()
	missle.global_position = get_parent().global_position
	missle.global_rotation = get_parent().global_rotation
	get_tree().current_scene.add_child(missle)
	queue_free()
	Tool.play_sound_2d(get_tree().current_scene, "res://sounds/weapon/dagger_woosh.mp3", missle.global_position)
