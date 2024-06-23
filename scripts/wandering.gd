extends Node
class_name Wandering

var count = 0
var wandering_loc: Vector2 = Vector2(0, 0)

func _ready():
	count = randi_range(5 * 50, 10 * 50)
	wandering_loc = owner.global_position
	
func _process(delta):
	if count == 0:
		_on_wandering_timer_timeout()
		count = randi_range(5 * 50, 10 * 50)
	else:
		count -= 1

func _on_wandering_timer_timeout():
	var r = deg_to_rad(randf_range(0, 360.0))
	var d = randf_range(100.0, 1000.0)
	var x = owner.global_position.x + cos(r) * d
	var y = owner.global_position.y + sin(r) * d
	wandering_loc = Vector2(x, y)
