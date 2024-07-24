extends Lootable

const I_DAGGER = preload("res://scenes/i_dagger.tscn")

func loot(player):
	if visible && player.item_handle.get_child_count() == 0:
		var dagger = I_DAGGER.instantiate()
		visible = false
		player.item_handle.add_child(dagger)
		player.gaven_new_item(dagger)

func _sub_ready():
	lootable = false
