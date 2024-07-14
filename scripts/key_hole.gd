extends Node2D

var door := []

func open_gate():
	print("open gate!!!")
	for v in door:
		get_tree().current_scene.tile_map.set_cell(0, Vector2i(v[0], v[1]), 0, Vector2i(0, 1), 0)
