extends Node
class_name TargetFinder

var target
@export var letgo_factor = 2.0

func _process(delta):
	find_target()

func find_target():
	if target and is_instance_valid(target):
		if owner.global_position.distance_to(target.global_position) > owner.alert_range * letgo_factor:
			target = null
		else:
			return
	else:
		target = null
	var nodes_in_group = get_tree().get_nodes_in_group("human")
	for node in nodes_in_group:
		if node.is_in_group("death"):
			continue
		if owner.global_position.distance_to(node.global_position) <= owner.alert_range:
			target = node
