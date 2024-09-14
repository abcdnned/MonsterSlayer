extends Unit

@onready var sword_swing_sound = $sword_swing_sound
@onready var sword_hit = $sword_hit
@onready var damage_zone = $Sprite2D/damage_zone
@onready var damage_zone_2 = $Sprite2D/damage_zone2
@onready var death_sound = $death
@onready var dash_cooldown = $dash_cooldown
@onready var dash_sound = $dash_sound
@onready var shield_hit = $shield_hit
@onready var item_handle = $Sprite2D/ItemHandle
@onready var sprint_dust = $SprintDust

const dash_dust = preload("res://scenes/dash_dust.tscn")
signal hero_death
signal map_pos_change(x, y)
const WALK_SPEED = 550.0
const GUARD_SPEED = 330.0
const SPRINT_SPEED = 880.0

var speed = WALK_SPEED

var dash_direction = Vector2.ZERO
const DASH_MAX_SPEED = 1540.0
var dash_speed = DASH_MAX_SPEED
const DASH_ATTACK_MAX_SPEED = 1210.0
var dash_attack_speed = DASH_ATTACK_MAX_SPEED
var dash_attack_direction = Vector2.ZERO
var dash_attack_deduction = 20.0
var map_pos = Vector2(4, 4)
const TYPE = "KnightWeaponSuit"
var sprint = false

func _process(delta):
	super._process(delta)
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
			if Input.is_action_just_pressed("right_click") and consume(3):
				animation_tree.set("parameters/conditions/special_attack", true)
			elif Input.is_action_pressed("item"):
				if item_handle.get_child_count() > 0:
					animation_tree.set("parameters/conditions/hold_item", true)
					animation_tree.set("parameters/conditions/hide_item", false)
			elif Input.is_action_just_pressed("sprint") && dash_cooldown.is_stopped() && consume(1):
				dash_direction = get_direction()
				animation_tree.set("parameters/conditions/dash", true)
				dash_cooldown.start()
				sprint = true
			elif sprint and Input.is_action_pressed("sprint") and get_input() == Vector2(0.0, -1.0) and Input.is_action_just_pressed("left_click") && consume(1):
				animation_tree.set("parameters/conditions/dash_attack", true)
				dash_attack_speed = DASH_ATTACK_MAX_SPEED
				dash_attack_deduction = 20.0
				dash_attack_direction = Vector2(cos(sprite.rotation), sin(sprite.rotation)).normalized()
			elif Input.is_action_just_pressed("left_click") and consume(1):
				animation_tree.set("parameters/conditions/attack", true)
			elif get_input() == Vector2(0.0, 1.0):
				animation_tree.set("parameters/conditions/defense", true)
			_move_velocity(delta)
			move_and_slide()	
		"swap":
			animation_tree.set("parameters/conditions/attack", false)
		"lightning_strike":
			animation_tree.set("parameters/conditions/special_attack", false)
			velocity = dash_attack_direction * dash_attack_speed
			dash_attack_speed = clampf(dash_attack_speed - dash_attack_deduction, 0, dash_attack_speed)
			move_and_slide()
		"dying":
			damage_zone.monitoring = false
			damage_zone_2.monitoring = false
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
		"Idle_Defense":
			animation_tree.set("parameters/conditions/defense", false)
			var mouse_pos = get_global_mouse_position()
			sprite.look_at(mouse_pos)
			var direction = get_direction()
			if direction:
				speed = GUARD_SPEED
				velocity = direction * speed
			else:
				velocity = velocity.lerp(Vector2.ZERO, delta * 20)
			move_and_slide()
			if not get_input() == Vector2(0.0, 1.0):
				animation_tree.set("parameters/conditions/defense_cancel", true)
		"idle_defense_cancel":
			animation_tree.set("parameters/conditions/defense_cancel", false)
		"idle_defense_hit":
			animation_tree.set("parameters/conditions/defense_hit", false)
			var direction = knock_back_source_position.direction_to(global_position).normalized()
			velocity = direction * knock_back_force
			knock_back_force = clamp(knock_back_force - 10.0, 0.0, knock_back_force)
			move_and_slide()
		"HoldItem":
			animation_tree.set("parameters/conditions/attack", false)
			animation_tree.set("parameters/conditions/dash_attack", false)
			if Input.is_action_just_pressed("left_click"):
				animation_tree.set("parameters/conditions/use_item", true)
			elif Input.is_action_just_pressed("sprint") && dash_cooldown.is_stopped():
				dash_direction = get_direction()
				animation_tree.set("parameters/conditions/dash", true)
				dash_cooldown.start()
				sprint = true
			elif Input.is_action_pressed("right_click"):
				animation_tree.set("parameters/conditions/drop_item", true)
				drop()
			else:
				_move_velocity(delta)
				move_and_slide()
		"use_item":
			animation_tree.set("parameters/conditions/use_item", false)
		"drop_item":
			animation_tree.set("parameters/conditions/drop_item", false)
		"interact":
			animation_tree.set("parameters/conditions/attack", false)
			animation_tree.set("parameters/conditions/interact", false)

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
	health = max_health
	emit_signal("health_change", health)

func _move_velocity(delta):
	var direction = get_direction()
	var input = get_input()
	if direction:
		if sprint and Input.is_action_pressed("sprint") and input == Vector2(0.0, -1.0) and abs(Vector2(1, 0).rotated(sprite.rotation).angle_to(dash_direction)) <= deg_to_rad(Globals.DASH_ANGEL):
			speed = SPRINT_SPEED
			sprint_dust.emitting = true
		else:
			sprint = false
			speed = WALK_SPEED
			sprint_dust.emitting = false
		velocity = direction * speed
	else:
		sprint = false
		velocity = velocity.lerp(Vector2.ZERO, delta * 20)
		
func _sword_swing():
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
	
func dash_attack_stop():
	dash_attack_deduction = 40.0
	
func dash_attack_sound():
	sword_swing_sound.play()

func _take_damage(d, v, source_position, tick):
	match state_machine.get_current_node():
		"Idle_Defense":
			var hit_angel = Vector2(cos(sprite.global_rotation), sin(sprite.global_rotation)).angle_to((source_position - global_position))
			if abs(hit_angel) < deg_to_rad(40.0):
				self.knock_back_force = v
				self.knock_back_source_position = source_position
				animation_tree.set("parameters/conditions/defense_hit", true)
				shield_hit.play()
				return [true, 0]
			else:
				super._take_damage(d, v, source_position, tick)
		"idle_defense_hit":
			var hit_angel = Vector2(cos(sprite.global_rotation), sin(sprite.global_rotation)).angle_to((source_position - global_position))
			if abs(hit_angel) < deg_to_rad(40.0):
				self.knock_back_force = v
				self.knock_back_source_position = source_position
				state_machine.start("idle_defense_hit", true)
				shield_hit.play()
				return [true, 0]
			else:
				super._take_damage(d, v, source_position, tick)
		_:
			super._take_damage(d, v, source_position, tick)
	return [false, d]


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
	
func interact(o):
	animation_tree.set("parameters/conditions/interact", true)

func dash_attack():
	dash_attack_speed = 660
	dash_attack_deduction = 20.0
	dash_attack_direction = (get_global_mouse_position() - global_position).normalized()

func dash_attack_successor():
	dash_attack_speed = 660
	dash_attack_deduction = 20.0

