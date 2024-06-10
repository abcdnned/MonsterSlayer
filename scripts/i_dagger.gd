extends Sprite2D

const FLYING_DAGGER = preload("res://scenes/flying_dagger.tscn")

func shoot():
	var dagger = FLYING_DAGGER.instantiate()
	dagger.global_position = get_parent().global_position
	dagger.global_rotation = get_parent().global_rotation
	owner.get_parent().add_child(dagger)
	Tool.play_sound_2d(owner, "res://sounds/dagger_woosh.mp3", dagger.global_position)
