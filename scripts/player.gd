extends Unit

@onready var player_sprite = $Sprite2D
@onready var sword_swing_sound = $sword_swing_sound
@onready var sword_hit = $sword_hit
@onready var sword_hit_2 = $sword_hit2
@onready var damage_zone = $Sprite2D/damage_zone
@onready var sprite_2d = $Sprite2D
@onready var death_sound = $death
@onready var dash_cooldown = $dash_cooldown
@onready var dash_sound = $dash_sound
const dash_dust = preload("res://scenes/dash_dust.tscn")

signal hero_death
const WALK_SPEED = 500.0
const SPRINT_SPEED = 800.0

var speed = WALK_SPEED

var dash_direction = Vector2.ZERO
const DASH_MAX_SPEED = 1400.0
var dash_speed = DASH_MAX_SPEED


func _process(delta):
	match state_machine.get_current_node():
		"Idle_2":
			var mouse_pos = get_global_mouse_position()
			player_sprite.look_at(mouse_pos)
			animation_tree.set("parameters/conditions/unstun", false)
		"dying":
			animation_tree.set("parameters/conditions/dying", false)

		
func _physics_process(delta):
	match state_machine.get_current_node():
		"Idle_2":
			if Input.is_action_pressed("left_click"):
				animation_tree.set("parameters/conditions/attack", true)
			elif Input.is_action_just_pressed("sprint") && dash_cooldown.is_stopped():
				dash_direction = get_direction()
				animation_tree.set("parameters/conditions/dash", true)
				dash_cooldown.start()
			else:
				_move_velocity(delta)
				move_and_slide()	
		"swap":
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

func get_direction():
	var mouse_pos = get_global_mouse_position()
	var forward = (mouse_pos - global_position).normalized()
	var right = forward.rotated(deg_to_rad(90))
	var input = get_input()
	var direction = (forward * -input.y + right * input.x).normalized()
	return direction

func get_input():
	return Input.get_vector("left", "right", "up", "down")

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
		
func _sword_swing():
	sword_swing_sound.play()

func _death():
	_apply_dying_shader()
	death_sound.play()
	
	
func _apply_dying_shader():
	var shader = load("res://shader/dying.gdshader")
	var shader_material = ShaderMaterial.new()
	shader_material.shader = shader
	sprite_2d.material = shader_material

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
		
