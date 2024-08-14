extends Sprite2D
class_name Lootable

var lootable = true
const pick_up_dis = 600.0
var p = null

func _ready():
	add_to_group("lootable")
	_sub_ready()
	
func _sub_ready():
	pass

func _process(delta):
	if lootable and is_on_top() and is_reachable():
		apply_pickable_shader(self)
	else:
		material = null

func _input(event):
	if is_left_mouse_button_pressed(event) and lootable and is_on_top() and is_reachable():
		loot(get_tree().current_scene.player)

func is_left_mouse_button_pressed(event):
	return event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT

func apply_pickable_shader(sprite):
	var shader = load("res://shader/pickable.gdshader")
	var shader_material = ShaderMaterial.new()
	shader_material.shader = shader
	sprite.material = shader_material
	
func loot(player):
	if not visible:
		return
	if player.item_handle.get_child_count() == 0:
		reparent(player.item_handle, false)
		position = Vector2(0, 0)
		player.gaven_new_item(self)
		p = player
		lootable = false

func drop(pos):
	if typeof(pos) == TYPE_VECTOR2:
		reparent(get_tree().current_scene, false)
		global_position = pos
	else:
		reparent(pos, false)
		position = Vector2(64, 64)
	p = null
	lootable = true

func is_on_top():
	var top = null
	for l in get_tree().get_nodes_in_group("lootable"):
		if is_intersect(l) and (top == null or l.is_greater_than(top)):
			top = l
	return top == self
	
func is_intersect(l):
	return l.global_position.distance_to(get_global_mouse_position()) < 50.0

func is_reachable():
	var pp = get_tree().current_scene.player.global_position
	return pp.distance_to(get_global_mouse_position()) <= pick_up_dis
