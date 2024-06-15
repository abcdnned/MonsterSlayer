extends Sprite2D
class_name Lootable

var lootable = false
const pick_up_dis = 500.0

func _process(delta):
	if lootable and get_rect().has_point(to_local(get_global_mouse_position())) and get_tree().current_scene.player.global_position.distance_to(get_global_mouse_position()) <= pick_up_dis:
		apply_pickable_shader(self)
	else:
		material = null

func _input(event):
	if lootable and event is InputEventKey and event.pressed and event.as_text_physical_keycode() == "E":
		if get_rect().has_point(to_local(get_global_mouse_position())) and get_tree().current_scene.player.global_position.distance_to(get_global_mouse_position()) <= pick_up_dis:
			loot(get_tree().current_scene.player)

func apply_pickable_shader(sprite):
	var shader = load("res://shader/pickable.gdshader")
	var shader_material = ShaderMaterial.new()
	shader_material.shader = shader
	sprite.material = shader_material
	
func loot(player):
	pass
