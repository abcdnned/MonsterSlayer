extends Sprite2D
class_name AutoPickable

var pickable = true
const pick_up_dis = 100.0
var tick = 0

func _ready():
	_sub_ready()
	
func _sub_ready():
	pass

func _process(delta):
	if pickable and tick % 5 == 0:
		var player_pos = get_tree().current_scene.player.global_position
		if pickable and player_pos.distance_to(global_position) <= pick_up_dis:
			auto_pickup(get_tree().current_scene.player)
			pickable = false
			visible = false
	tick += 1
			
func auto_pickup(player):
	pass
