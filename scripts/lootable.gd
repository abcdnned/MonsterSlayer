extends Sprite2D
class_name Lootable

@export var price = 10

var lootable = true
const pick_up_dis = 600.0
var p = null
var tooltip_panel = null

func _ready():
	z_index = 8
	add_to_group("lootable")
	create_tooltip()
	_sub_ready()
	
func _sub_ready():
	pass

func _process(delta):
	if lootable and is_on_top() and is_reachable():
		apply_pickable_shader(self)
		if is_selling():
			show_tooltip("100")
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

func is_selling():
	# Implement your logic to determine if the item is selling
	return true # Placeholder return value for demonstration

func create_tooltip():
	tooltip_panel = Panel.new()
	var container = HFlowContainer.new()
	
	var coin_icon: TextureRect = TextureRect.new()
	coin_icon.texture = load("res://sprites/coin_icon.png")
	coin_icon.custom_minimum_size = Vector2(32, 32)  # Set a minimum size for the icon

	var label = Label.new()
	label.name = "TooltipLabel"
	
	container.add_child(coin_icon)
	container.add_child(label)
	tooltip_panel.add_child(container)
	
	tooltip_panel.set_visible(false)
	tooltip_panel.custom_minimum_size = Vector2(200, 50) # Set a minimum size
	add_child(tooltip_panel)

func move_tooltip(position):
	tooltip_panel.position = position

func show_tooltip(text):
	var label = tooltip_panel.get_child(0).get_child(1)
	label.text = text
	tooltip_panel.set_visible(true)
	move_tooltip(get_global_mouse_position() + Vector2(10, -20)) # Offset for better visibility

func hide_tooltip():
	if tooltip_panel.visible:
		tooltip_panel.set_visible(false)
	
