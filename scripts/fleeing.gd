extends Node
class_name Fleeing

var count = 0
var fleeing_loc: Vector2 = Vector2(0, 0)

func _ready():
	count = randi_range(1 * 50, 2 * 50)
	fleeing_loc = owner.global_position
	
func _process(delta):
	if count == 0:
		execute_flee()
		count = randi_range(1 * 50, 2 * 50)
	else:
		count -= 1

func execute_flee():
	if get_parent().target_finder.target:
		var a: Vector2 = get_parent().target_finder.target.global_position
		var b: Vector2 = owner.global_position
		var r = deg_to_rad(rad_to_deg(a.angle_to(b)) + randf_range(-15.0, 15.0))
		var d = randf_range(800.0, 1000.0)
		var x = owner.global_position.x + cos(r) * d
		var y = owner.global_position.y + sin(r) * d
		fleeing_loc = Vector2(x, y)
