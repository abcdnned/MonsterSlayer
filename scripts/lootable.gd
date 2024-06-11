extends Sprite2D

const pick_up_dis = 300.0

func _input(event):
	if event is InputEventKey and event.pressed and event.as_text_physical_keycode() == "E":
		if get_rect().has_point(to_local(get_global_mouse_position())) and owner.get_parent().player.global_position.distance_to(get_global_mouse_position()) <= pick_up_dis:
			get_parent().loot(owner.get_parent().player)
