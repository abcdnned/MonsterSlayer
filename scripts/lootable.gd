extends Sprite2D
class_name Lootable

var lootable = false
const pick_up_dis = 500.0
var p = null

func _ready():
	lootable = true
	add_to_group("lootable")

func _process(delta):
	if lootable and get_rect().has_point(to_local(get_global_mouse_position())) and get_tree().current_scene.player.global_position.distance_to(get_global_mouse_position()) <= pick_up_dis:
		if is_on_top():
			apply_pickable_shader(self)
	else:
		material = null

func _input(event):
	if lootable and event is InputEventKey and event.pressed and event.as_text_physical_keycode() == "Q":
		if get_rect().has_point(to_local(get_global_mouse_position())) and get_tree().current_scene.player.global_position.distance_to(get_global_mouse_position()) <= pick_up_dis and is_on_top():
			loot(get_tree().current_scene.player)

func apply_pickable_shader(sprite):
	var shader = load("res://shader/pickable.gdshader")
	var shader_material = ShaderMaterial.new()
	shader_material.shader = shader
	sprite.material = shader_material
	
func loot(player):
	if not visible:
		return
	if player.item_handle.get_child_count() == 1:
		player.item_handle.get_child(0).drop(get_global_mouse_position())
	if player.item_handle.get_child_count() == 0:
		reparent(player.item_handle, false)
		position = Vector2(0, 0)
		player.gaven_new_item(self)
		p = player
		lootable = false

func drop(pos):
	reparent(get_tree().current_scene, false)
	global_position = pos
	p = null
	lootable = true

func is_on_top():
	for l in get_tree().get_nodes_in_group("lootable"):
		if get_rect().has_point(to_local(l.global_position)) and is_greater_than(l):
			return false
	return true
