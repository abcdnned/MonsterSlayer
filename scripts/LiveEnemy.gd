extends Label

var internval_seconds = 1
var tick = 0

func _process(delta):
	tick += 1
	if (tick / 50 >= internval_seconds):
		tick = 0
	else:
		return
	text = "Live Enemy: " + str(get_live_enemy_count())
	
func get_live_enemy_count():
	var mobs = get_tree().get_nodes_in_group("mob")
	var c = 0
	for mob in mobs:
		if not mob.is_in_group("dead"):
			c += 1
	return c
