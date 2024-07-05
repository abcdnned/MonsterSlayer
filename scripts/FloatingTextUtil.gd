extends Node
class_name FloatingTextUtil

const FLOATING_TEXT = preload("res://scenes/floating_text.tscn")

func create_floating_text(pos, text, color):
	var f = FLOATING_TEXT.instantiate()
	f.global_position = pos
	f.find_child("Label").text = text
	f.find_child("Label").set("theme_override_colors/font_color",color) 
	get_tree().current_scene.add_child(f)
