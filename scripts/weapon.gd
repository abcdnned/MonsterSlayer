extends Lootable
class_name Weapon

@export var weapon_type: String

func loot(player):
	var item = null
	if player.item_handle.get_child_count() == 1:
		item = player.item_handle.get_child(0)
		item.reparent(get_tree().current_scene, false)
	if get_tree().current_scene.player.TYPE == "KnightWeaponSuit":
		var weapon = load("res://scenes/i_knight_weapon_suit.tscn").instantiate()
		weapon.global_position = global_position
		get_tree().current_scene.add_child(weapon)
	elif get_tree().current_scene.player.TYPE == "HeavySpear":
		var weapon = load("res://scenes/i_heavy_spear.tscn").instantiate()
		weapon.global_position = global_position
		get_tree().current_scene.add_child(weapon)
	elif get_tree().current_scene.player.TYPE == "Hammer":
		var weapon = load("res://scenes/i_hammer.tscn").instantiate()
		weapon.global_position = global_position
		get_tree().current_scene.add_child(weapon)
	get_tree().current_scene.load_player(load(weapon_type), player.global_position, { "health": player.health, "max_health": player.max_health })
	if item != null:
		item.reparent(get_tree().current_scene.player.item_handle, false)
	queue_free()
