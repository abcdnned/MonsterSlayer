extends Unit

const SPEED = 350
@onready var navigation_agent_2d = $NavigationAgent2D
@onready var collision_shape_2d = $CollisionShape2D
@onready var death_yell = $death_yell
@onready var target_finder = $TargetFinder
@onready var wandering = $Wandering
var last_ray_hit_dis = 800
const FLYING_BOOMER = preload("res://scenes/flying_boomer.tscn")

var alert_range = 1000.0

	
func _process(delta):
	match state_machine.get_current_node():
		"chasing":
			if is_in_group("lose"):
				return
			var dis = global_position.distance_to(target_finder.target.global_position)
			if dis <= alert_range:
				last_ray_hit_dis = dis
				sprite.look_at(target_finder.target.global_position)
				animation_tree.set("parameters/conditions/attack", true)
		"attack":
			animation_tree.set("parameters/conditions/attack", false)
			if state_machine.get_current_play_position() <= 0.4:
				sprite.look_at(target_finder.target.global_position)

func _physics_process(delta):
	match state_machine.get_current_node():
		"wandering":
			if target_finder.target:
				animation_tree.set("parameters/conditions/target", true)
				animation_tree.set("parameters/conditions/wandering", false)
			else:
				animation_tree.set("parameters/conditions/target", false)
				animation_tree.set("parameters/conditions/wandering", true)
				if global_position.distance_to(navigation_agent_2d.get_next_path_position()) > 10.0:
					var direction = to_local(navigation_agent_2d.get_next_path_position()).normalized()
					sprite.look_at(navigation_agent_2d.get_next_path_position())
					velocity = direction * SPEED
					move_and_slide()
		"chasing":
			if target_finder.target:
				var direction = to_local(navigation_agent_2d.get_next_path_position()).normalized()
				sprite.look_at(navigation_agent_2d.get_next_path_position())
				velocity = direction * SPEED
				move_and_slide()
			else:
				animation_tree.set("parameters/conditions/wandering", true)
				animation_tree.set("parameters/conditions/target", false)
		"dying":
			animation_tree.set("parameters/conditions/dying", false)
			var direction = knock_back_source_position.direction_to(global_position).normalized()
			velocity = direction * knock_back_force
			knock_back_force = clamp(knock_back_force - 10.0, 0.0, knock_back_force)
			move_and_slide()
		"stun":
			animation_tree.set("parameters/conditions/stun", false)
			if stun_ticks > 0:
				stun_ticks -= 1
				var direction = knock_back_source_position.direction_to(global_position).normalized()
				velocity = direction * knock_back_force
				knock_back_force = clamp(knock_back_force - 10.0, 0.0, knock_back_force)
				move_and_slide()
			else:
				animation_tree.set("parameters/conditions/unstun", true)


func _on_timer_timeout():
	if target_finder.target:
		navigation_agent_2d.target_position = target_finder.target.global_position
	else:
		navigation_agent_2d.target_position = wandering.wandering_loc
		
func _sub_dead():
	death_yell.play()
	#drop_boom()

#func drop_boom():
	# TODO
	#if false and item_back.get_child_count() == 1:
		#var key = item_back.get_child(0)
		#key.lootable = true
		#key.reparent(get_tree().current_scene, true)
		#key.rotation_degrees = 0
				
func shoot():
	var boomer = FLYING_BOOMER.instantiate()
	boomer.dis = last_ray_hit_dis
	boomer.global_position = global_position
	boomer.global_rotation = sprite.global_rotation
	get_tree().current_scene.add_child(boomer)
	Tool.play_sound_2d(get_tree().current_scene, "res://sounds/weapon/dagger_woosh.mp3", boomer.global_position)
