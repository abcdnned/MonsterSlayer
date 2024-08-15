extends NinePatchRect

const GENERAL_SLOTS = preload("res://scenes/general_slots.tscn")
@onready var grid_container = $GridContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func add_item(item):
	var s = GENERAL_SLOTS.instantiate()
	s.add_child(item)
	grid_container.add_child(s)

func clear_all_items():
	Tool.remove_all_children(grid_container)
