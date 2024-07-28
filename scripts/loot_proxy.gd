extends Lootable

@export var item_path: String

func loot(player):
	if visible && player.item_handle.get_child_count() == 0:
		var item = load(item_path).instantiate()
		visible = false
		player.item_handle.add_child(item)
		player.gaven_new_item(item)

func _sub_ready():
	lootable = false
