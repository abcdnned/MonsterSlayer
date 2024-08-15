extends Node2D

signal interact(player: Node2D)

var interactable = true
const interactable_dis = 600.0

func _ready():
	add_to_group("lootable")

func _process(delta):
	if interactable and get_parent().get_rect().has_point(to_local(get_global_mouse_position())) and get_tree().current_scene.player.global_position.distance_to(get_global_mouse_position()) <= interactable_dis:
		if is_on_top():
			apply_pickable_shader(get_parent())
	else:
		get_parent().material = null

func _input(event):
	if interactable_dis and is_left_mouse_button_pressed(event):
		if get_parent().get_rect().has_point(to_local(get_global_mouse_position())) and get_tree().current_scene.player.global_position.distance_to(get_global_mouse_position()) <= interactable_dis and is_on_top():
			get_tree().current_scene.player.interact(get_parent().get_parent())
			emit_signal("interact", get_tree().current_scene.player)	

func is_left_mouse_button_pressed(event):
	return event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT

func apply_pickable_shader(sprite):
	var shader = load("res://shader/pickable.gdshader")
	var shader_material = ShaderMaterial.new()
	shader_material.shader = shader
	sprite.material = shader_material

func is_on_top():
	for l in get_tree().get_nodes_in_group("lootable"):
		if get_parent().get_rect().has_point(to_local(l.global_position)) and is_greater_than(l):
			return false
	return true
