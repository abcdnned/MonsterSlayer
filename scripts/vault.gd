extends Pickable

func sub_pickup(player):
	var world = get_tree().current_scene
	if world.two_key_obtained():
		print(" open vault ")
		world.win()
	else:
		print("you need to obtain both red key and green key")
