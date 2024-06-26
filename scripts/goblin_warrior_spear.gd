extends Unit

const SPEED = 400
@onready var navigation_agent_2d = $NavigationAgent2D
@onready var collision_shape_2d = $CollisionShape2D
@onready var death_yell = $death_yell
@onready var ray_cast_2d = $Sprite2D/RayCast2D
@onready var damage_zone = $Sprite2D/Weapon/damage_zone
@onready var target_finder = $TargetFinder
@onready var wandering = $Wandering

var alert_range = 1000.0

	
func _process(delta):
	match state_machine.get_current_node():
		"chasing":
			if is_in_group("lose"):
				return
			if ray_cast_2d.is_colliding():
				if ray_cast_2d.get_collider().is_in_group("human"):
					animation_tree.set("parameters/conditions/attack", true)
		"HeavySpear_Attack":
			animation_tree.set("parameters/conditions/attack", false)

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
			animation_tree.set("parameters/conditions/unstun", false)
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
			damage_zone.monitoring = false
		"stun":
			animation_tree.set("parameters/conditions/stun", false)
			damage_zone.monitoring = false
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
		if global_position.distance_to(target_finder.target.global_position) >= 70:
			var dir = (target_finder.target.global_position - global_position).normalized()
			navigation_agent_2d.target_position = target_finder.target.global_position + dir * 70
		else:
			navigation_agent_2d.target_position = global_position
	else:
		navigation_agent_2d.target_position = wandering.wandering_loc
	
func _sub_dead():
	death_yell.play()

				
