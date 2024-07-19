extends Node2D

var door := []

func open_gate():
	Tool.play_sound_2d(get_tree().current_scene, "res://sounds/open_gate.wav", position)
	for v in door:
		get_tree().current_scene.tile_map.set_cell(0, Vector2i(v[0], v[1]), 0, Vector2i(0, 1), 0)
