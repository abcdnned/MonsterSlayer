extends Lootable

@export var missle_type: String

func shoot():
	var missle = load(missle_type).instantiate()
	missle.global_position = get_parent().global_position
	missle.global_rotation = get_parent().global_rotation
	get_tree().current_scene.add_child(missle)
	queue_free()
	Tool.play_sound_2d(get_tree().current_scene, "res://sounds/weapon/dagger_woosh.mp3", missle.global_position)
