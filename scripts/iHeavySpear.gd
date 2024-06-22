extends Lootable

const I_WEAPON_SUIT = preload("res://scenes/i_weapon_suit.tscn")
const I_HEAVY_SPEAR = preload("res://scenes/i_heavy_spear.tscn")

func loot(player):
	var position = player.global_position
	var item = null
	if player.item_handle.get_child_count() == 1:
		item = player.item_handle.get_child(0)
		item.reparent(get_tree().current_scene, false)
	if get_tree().current_scene.player.TYPE == "KnightWeaponSuit":
		var weapon = I_WEAPON_SUIT.instantiate()
		weapon.global_position = global_position
		get_tree().current_scene.add_child(weapon)
	elif get_tree().current_scene.player.TYPE == "HeavySpear":
		var weapon = I_HEAVY_SPEAR.instantiate()
		weapon.global_position = global_position
		get_tree().current_scene.add_child(weapon)
	get_tree().current_scene.load_player(get_tree().current_scene.PLAYER_SPEAR, position)
	if item != null:
		item.reparent(get_tree().current_scene.player.item_handle, false)
	queue_free()


