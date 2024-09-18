extends Unit

const SPEED = 550
@onready var navigation_agent_2d = $NavigationAgent2D
@onready var collision_shape_2d = $CollisionShape2D
@onready var death_yell = $death_yell
@onready var ray_cast_2d = $Sprite2D/RayCast2D
@onready var dagger_attack_sound = $dagger_attack_sound
@onready var damage_zone = $Sprite2D/damage_zone
@onready var dagger_sprite = $Sprite2D/DaggerSprite
@onready var target_finder = $TargetFinder
@onready var wandering = $Wandering
@onready var item_back = $Sprite2D/ItemBack
@onready var what_am_i_thinking = $WhatAmIThinking

var alert_range = 500.0
const DASH_ATTACK_MAX_SPEED = 1210.0
var dash_attack_speed = DASH_ATTACK_MAX_SPEED
var dash_attack_direction = Vector2.ZERO
var dash_attack_deduction = 20.0
	
func _process(delta):
	super._process(delta)
	match state_machine.get_current_node():
		"chasing":
			if stamina == 0:
				animation_tree.set("parameters/conditions/defense", true)
			if is_in_group("lose"):
				return
			if ray_cast_2d.is_colliding() and ray_cast_2d.get_collider().is_in_group("human"):
				if what_am_i_thinking.thinking <= 100:
					move_queue(2)
				else:
					move_queue(1)
		"attack":
			animation_tree.set("parameters/conditions/attack", false)
		"defense":
			animation_tree.set("parameters/conditions/defense", false)

func move_queue(t: int) -> void:
	var conditions = ["attack", "combo"]
	for i in range(t, 0, -1):  # This iterates from t to 0
		if consume(i):
			animation_tree.set("parameters/conditions/" + conditions[i - 1], true)
			return


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
			animation_tree.set("parameters/conditions/undefense", false)
			if target_finder.target:
				var direction = to_local(navigation_agent_2d.get_next_path_position()).normalized()
				sprite.look_at(navigation_agent_2d.get_next_path_position())
				velocity = direction * SPEED
				move_and_slide()
			else:
				animation_tree.set("parameters/conditions/wandering", true)
				animation_tree.set("parameters/conditions/target", false)
		"defense":
			animation_tree.set("parameters/conditions/defense", false)
			if target_finder.target && stamina == 0:
				var direction = global_position.direction_to(target_finder.target.global_position).normalized()
				sprite.look_at(target_finder.target.global_position)
				velocity = -direction * SPEED * 0.8
				move_and_slide()
			else:
				animation_tree.set("parameters/conditions/undefense", true)
		


func _on_timer_timeout():
	if target_finder.target:
		navigation_agent_2d.target_position = target_finder.target.global_position
	else:
		navigation_agent_2d.target_position = wandering.wandering_loc
	
func _dagger_attack():
	dagger_attack_sound.play()
		
func _sub_dead():
	dagger_sprite.lootable = true
	death_yell.play()
	drop_key()

func drop_key():
	if item_back.get_child_count() == 1:
		var key = item_back.get_child(0)
		key.lootable = true
		key.reparent(get_tree().current_scene, true)
		key.rotation_degrees = 0
				
