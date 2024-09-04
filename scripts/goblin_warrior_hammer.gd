extends Unit

const SPEED = 400
@onready var navigation_agent_2d = $NavigationAgent2D
@onready var collision_shape_2d = $CollisionShape2D
@onready var death_yell = $death_yell
@onready var ray_cast_2d = $Sprite2D/RayCast2D
@onready var damage_zone = $Sprite2D/Weapon/damage_zone
@onready var damage_zone_2 = $Sprite2D/Weapon/damage_zone2
@onready var target_finder = $TargetFinder
@onready var wandering = $Wandering
@onready var what_am_i_thinking = $WhatAmIThinking
@onready var shape_cast_2d = $Sprite2D/ShapeCast2D
@onready var hammer_attack = $HammerAttack
@onready var hammer_dash_attack = $HammerDashAttack
@onready var hammer_swap = $HammerSwap
const I_HAMMER = preload("res://scenes/i_hammer.tscn")
var dash_attack_speed = 1100
var dash_attack_direction = Vector2.ZERO
var dash_attack_deduction = 20.0

var alert_range = 1000.0

	
func _process(delta):
	super._process(delta)
	match state_machine.get_current_node():
		"chasing":
			if is_in_group("lose"):
				return
			if ray_cast_2d.is_colliding() and what_am_i_thinking.thinking < 50:
				if ray_cast_2d.get_collider().is_in_group("human"):
					animation_tree.set("parameters/conditions/attack", true)
			elif ray_cast_2d.is_colliding() and what_am_i_thinking.thinking < 70:
				if ray_cast_2d.get_collider().is_in_group("human"):
					animation_tree.set("parameters/conditions/swap", true)
					dash_attack_speed = 700
					dash_attack_deduction = 7.0
					dash_attack_direction = Vector2(cos(sprite.rotation), sin(sprite.rotation)).normalized()
			elif shape_cast_2d.is_colliding() and what_am_i_thinking.thinking < 10:
				for i in range(shape_cast_2d.get_collision_count()):
					if shape_cast_2d.get_collider(i).is_in_group("human"):
						animation_tree.set("parameters/conditions/dash_attack", true)
						dash_attack_speed = 1100
						dash_attack_deduction = 20.0
						dash_attack_direction = Vector2(cos(sprite.rotation), sin(sprite.rotation)).normalized()
						break
		"attack":
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
					navigation_move()
		"chasing":
			animation_tree.set("parameters/conditions/unstun", false)
			if target_finder.target:
				var direction = to_local(navigation_agent_2d.get_next_path_position()).normalized()
				sprite.look_at(navigation_agent_2d.get_next_path_position())
				velocity = direction * SPEED
				navigation_move()
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
		"dash_attack":
			animation_tree.set("parameters/conditions/dash_attack", false)
			velocity = dash_attack_direction * dash_attack_speed
			dash_attack_speed = clampf(dash_attack_speed - dash_attack_deduction, 0, dash_attack_speed)
			move_and_slide()
		"swap":
			animation_tree.set("parameters/conditions/swap", false)
			if state_machine.get_current_play_position() >= 0.18:
				velocity = dash_attack_direction * dash_attack_speed
				dash_attack_speed = clampf(dash_attack_speed - dash_attack_deduction, 0, dash_attack_speed)
				move_and_slide()

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
	drop_hammer()

func drop_hammer():
	var hammer = I_HAMMER.instantiate()
	hammer.position = global_position
	get_tree().current_scene.add_child(hammer)
	
func pole_attack_hit():
	damage_zone_2.knockback = 1500
	
func pole_attack_unhit():
	damage_zone_2.knockback = 1000
	
func on_attack():
	hammer_attack.play()
	
func on_dash_attack():
	hammer_dash_attack.play()
	
func on_swap():
	hammer_swap.play()


func _on_navigation_agent_2d_velocity_computed(safe_velocity):
	velocity = safe_velocity
	move_and_slide()

func navigation_move():
	if navigation_agent_2d.avoidance_enabled:
		navigation_agent_2d.set_velocity(velocity)
	else:
		move_and_slide()
