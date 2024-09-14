extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_pressed():
	# Load the scene named "world"
	var error = get_tree().change_scene_to_file("res://scenes/world.tscn")
	if error != OK:
		print("Failed to load the scene 'world'")
