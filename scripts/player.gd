extends CharacterBody2D

var state_machine
@onready var player_sprite = $Sprite2D
@onready var anim = $AnimationPlayer
@onready var animation_tree = $AnimationTree
@onready var sword_swing_sound = $sword_swing_sound
@onready var sword_hit = $sword_hit
@onready var sword_hit_2 = $sword_hit2
@onready var damage_zone = $Sprite2D/damage_zone
@onready var sprite_2d = $Sprite2D
@onready var death = $death

signal health_change(health)
signal max_health_change(max_health)
signal hero_death


const WALK_SPEED = 500.0
const SPRINT_SPEED = 800.0

var health = 3.0
var max_health = 3.0
var knock_back_force
var stun_ticks
var knock_back_source_position


var speed = WALK_SPEED

func _ready():
	state_machine = animation_tree.get("parameters/playback")
	emit_signal("health_change", health)
	emit_signal("max_health_change", max_health)

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

func _move_velocity(delta):
	var mouse_pos = get_global_mouse_position()
	var direction = Input.get_vector("left", "right", "up", "down")
	if direction:
		if Input.is_action_pressed("sprint"):
			speed = SPRINT_SPEED
		else:
			speed = WALK_SPEED
		velocity = direction * speed
	else:
		velocity = velocity.lerp(Vector2.ZERO, delta * 20)
		
func _sword_swing():
	sword_swing_sound.play()
	
func _take_damage(d, v, source_position, tick):
	self.knock_back_force = v
	self.knock_back_source_position = source_position
	self.stun_ticks = tick
	health -= d
	emit_signal("health_change", health)
	emit_signal("max_health_change", max_health)
	if health <= 0:
		knock_back_force = knock_back_force / 2
		animation_tree.set("parameters/conditions/dying", true)
		add_to_group("dead")
	else:
		animation_tree.set("parameters/conditions/stun", true)

func _death():
	_apply_dying_shader()
	death.play()
	
	
func _apply_dying_shader():
	var shader = load("res://shader/dying.gdshader")
	var shader_material = ShaderMaterial.new()
	shader_material.shader = shader
	sprite_2d.material = shader_material

func _emit_hero_death():
	emit_signal("hero_death")
	
