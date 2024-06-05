extends Control

var tiles = []

func _ready():
	pass

func _on_world_map_change():
	for row in owner.map:
		print(row)
