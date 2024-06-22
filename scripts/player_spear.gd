extends Unit

@onready var sword_swing_sound = $sword_swing_sound
@onready var sword_hit = $sword_hit
@onready var damage_zone = $Sprite2D/Weapon/damage_zone
@onready var death_sound = $death
@onready var dash_cooldown = $dash_cooldown
@onready var dash_sound = $dash_sound
@onready var item_handle = $Sprite2D/ItemHandle

const dash_dust = preload("res://scenes/dash_dust.tscn")
signal hero_death
signal map_pos_change(x, y)
const WALK_SPEED = 500.0
const SPRINT_SPEED = 800.0

var speed = WALK_SPEED

var dash_direction = Vector2.ZERO
const DASH_MAX_SPEED = 1400.0
var dash_speed = DASH_MAX_SPEED
const DASH_ATTACK_MAX_SPEED = 1100.0
var dash_attack_speed = DASH_ATTACK_MAX_SPEED
var dash_attack_direction = Vector2.ZERO
var dash_attack_deduction = 20.0
var map_pos = Vector2(4, 4)
const TYPE = "HeavySpear"

func _process(delta):
	match state_machine.get_current_node():
		"Idle_2", "HoldItem":
			var mouse_pos = get_global_mouse_position()
			sprite.look_at(mouse_pos)
			animation_tree.set("parameters/conditions/unstun", false)
		"dying":
			animation_tree.set("parameters/conditions/dying", false)

		
func _physics_process(delta):
	match state_machine.get_current_node():
		"Idle_2":
			if Input.is_action_pressed("item"):
				if item_handle.get_child_count() > 0:
					animation_tree.set("parameters/conditions/hold_item", true)
					animation_tree.set("parameters/conditions/hide_item", false)
			elif Input.is_action_just_pressed("sprint") && dash_cooldown.is_stopped():
				dash_direction = get_direction()
				animation_tree.set("parameters/conditions/dash", true)
				dash_cooldown.start()
			elif Input.is_action_pressed("sprint") and get_input() == Vector2(0.0, -1.0) and Input.is_action_pressed("left_click"):
				animation_tree.set("parameters/conditions/dash_attack", true)
				dash_attack_speed = DASH_ATTACK_MAX_SPEED
				dash_attack_deduction = 20.0
				dash_attack_direction = Vector2(cos(sprite.rotation), sin(sprite.rotation)).normalized()
			elif Input.is_action_pressed("left_click"):
				animation_tree.set("parameters/conditions/attack", true)
			_move_velocity(delta)
			move_and_slide()
		"Attack":
			animation_tree.set("parameters/conditions/attack", false)
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
		"dying":
			var direction = knock_back_source_position.direction_to(global_position).normalized()
			velocity = direction * knock_back_force
			knock_back_force = clamp(knock_back_force - 10.0, 0.0, knock_back_force)
			move_and_slide()
		"dash":
			animation_tree.set("parameters/conditions/dash", false)
			velocity = dash_direction * dash_speed
			dash_speed -= 10.0
			move_and_slide()
		"dash_attack":
			animation_tree.set("parameters/conditions/dash_attack", false)
			velocity = dash_attack_direction * dash_attack_speed
			dash_attack_speed = clampf(dash_attack_speed - dash_attack_deduction, 0, dash_attack_speed)
			move_and_slide()
		"HoldItem":
			if Input.is_action_pressed("left_click"):
				animation_tree.set("parameters/conditions/hide_item", true)
				animation_tree.set("parameters/conditions/hold_item", false)
			elif Input.is_action_just_pressed("sprint") && dash_cooldown.is_stopped():
				dash_direction = get_direction()
				animation_tree.set("parameters/conditions/dash", true)
				dash_cooldown.start()
			elif Input.is_action_pressed("right_click"):
				animation_tree.set("parameters/conditions/use_item", true)
			elif Input.is_action_pressed("drop"):
				animation_tree.set("parameters/conditions/drop_item", true)
				drop()
			else:
				_move_velocity(delta)
				move_and_slide()
		"use_item":
			animation_tree.set("parameters/conditions/use_item", false)
		"drop_item":
			animation_tree.set("parameters/conditions/drop_item", false)

func get_direction():
	var mouse_pos = get_global_mouse_position()
	var forward = (mouse_pos - global_position).normalized()
	var right = forward.rotated(deg_to_rad(90))
	var input = get_input()
	var direction = (forward * -input.y + right * input.x).normalized()
	return direction

func get_input():
	return Input.get_vector("left", "right", "up", "down")

func _sub_ready():
	health = 3.0
	emit_signal("health_change", health)

func _move_velocity(delta):
	var direction = get_direction()
	var input = get_input()
	if direction:
		if Input.is_action_pressed("sprint") and input == Vector2(0.0, -1.0):
			speed = SPRINT_SPEED
		else:
			speed = WALK_SPEED
		velocity = direction * speed
	else:
		velocity = velocity.lerp(Vector2.ZERO, delta * 20)
		
func stub():
	sword_swing_sound.play()

func _sub_dead():
	death_sound.play()

func _emit_hero_death():
	emit_signal("hero_death")
	
func dash():
	if not dash_direction:
		dash_direction = -(get_global_mouse_position() - global_position).normalized()
	dash_speed = DASH_MAX_SPEED
	dash_sound.play()
	var dust = dash_dust.instantiate()
	dust.position = global_position
	dust.play("spawn")
	owner.add_child(dust)

func dash_second_attack():
	dash_attack_speed = DASH_ATTACK_MAX_SPEED * .8
	
func dash_attack_stop():
	dash_attack_deduction = 40.0
	
func dash_attack_sound():
	sword_swing_sound.play()
		
func _on_emit_signal_timeout():
	emit_signal("map_pos_change", global_position.x, global_position.y)
	
func throw_item():
	item_handle.get_child(0).shoot()
	animation_tree.set("parameters/conditions/hold_item", false)
	
func gaven_new_item(item):
	if item_handle.get_child_count() > 0:
		animation_tree.set("parameters/conditions/hold_item", true)
		animation_tree.set("parameters/conditions/hide_item", false)

func drop():
	item_handle.get_child(0).drop(get_global_mouse_position())
	animation_tree.set("parameters/conditions/hold_item", false)
	animation_tree.set("parameters/conditions/hide_item", true)
	
