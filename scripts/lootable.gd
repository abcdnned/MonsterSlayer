extends Sprite2D
class_name Lootable

@export var price = 10
@export var item_name = "placeholder:item"
@export_multiline var description = "placeholder:description"

var lootable = true
const pick_up_dis = 600.0
var p = null
var tooltip_panel = null
var tooltip = false
var tooltip_hover_timer = 0

func _ready():
	z_index = 8
	add_to_group("lootable")
	create_tooltip()
	_sub_ready()
	
func _sub_ready():
	pass

func _process(delta):
	if lootable and is_on_top() and is_reachable():
		tooltip_hover_timer += 1
		if tooltip_hover_timer > 50:
			tooltip = true
		apply_pickable_shader(self)
		if is_selling() || tooltip:
			show_tooltip()
	else:
		tooltip = false
		tooltip_hover_timer = 0
		hide_tooltip()
		material = null

func _input(event):
	if is_left_mouse_button_pressed(event) and lootable and is_on_top() and is_reachable():
		if is_selling():
			if get_tree().current_scene.money >= price:
				get_tree().current_scene.get_money(-price)
			else:
				return
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
	var parent_node = get_parent()
	for i in range(2):
		if parent_node == null:
			return false
		parent_node = parent_node.get_parent()
	return parent_node != null and parent_node.name == "MerchantsStore"
	
func create_tooltip():
	tooltip_panel = Panel.new()
	tooltip_panel.name = "Item Description"
	var main_container = VBoxContainer.new()
	main_container.name = "VBoxContainer"
	var top_container = HBoxContainer.new()
	top_container.name = "HBoxContainer"
	var item_name_label = Label.new()
	item_name_label.name = "ItemNameLabel"
	item_name_label.text = " " + item_name + " "
	item_name_label.set("theme_override_font_sizes/font_size", 32)
	item_name_label.custom_minimum_size = Vector2(50, 32)  # Optional: Set a minimum size for the label
	var coin_icon = TextureRect.new()
	coin_icon.name = "TextureRect"
	coin_icon.texture = load("res://sprites/coin_icon.png")
	coin_icon.custom_minimum_size = Vector2(32, 32)  # Set a minimum size for the icon
	var price_label = Label.new()
	price_label.name = "TooltipLabel"
	price_label.text = str(price) + " "
	price_label.set("theme_override_font_sizes/font_size", 32)
	price_label.custom_minimum_size = Vector2(0, 32)  # Optional: Set a minimum size for the label
	price_label.set("theme_override_colors/font_color", Color(1, 0.84, 0))  # Golden color
	top_container.add_child(item_name_label)
	top_container.add_child(coin_icon)
	top_container.add_child(price_label)
	main_container.add_child(top_container)
	var item_description_label = Label.new()
	item_description_label.name = "ItemDescriptionLabel"
	item_description_label.text = " " + description + " "
	item_description_label.set("theme_override_font_sizes/font_size", 32)
	item_description_label.custom_minimum_size = Vector2(0, 0)  # Optional: Set a minimum size for the label
	item_description_label.set("theme_override_colors/font_color", Color(0.73, 0.73, 0.73))  # Light gray color
	main_container.add_child(item_description_label)
	tooltip_panel.add_child(main_container)
	tooltip_panel.set_visible(false)
	add_child(tooltip_panel)

func move_tooltip(position):
	tooltip_panel.position = position
	tooltip_panel.size = tooltip_panel.get_child(0).size

func show_tooltip():
	tooltip_panel.visible = true
	move_tooltip(Vector2(-70, -170))
	
func hide_tooltip():
	if tooltip_panel.visible:
		tooltip_panel.set_visible(false)
	
