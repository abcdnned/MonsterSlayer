extends CharacterBody2D

var buier = null

var max_sell_dis = 1000

var collision_shape_2d: CollisionShape2D
@onready var merchants_store = $MerchantsStore
const I_HEALTH_POTION = preload("res://scenes/i_health_potion.tscn")

func _process(delta):
	if buier == null:
		merchants_store.visible = false
	elif buier.global_position.distance_to(global_position) > max_sell_dis:
		buier = null

func _ready():
	create_collision_shape()
	add_to_group("Facility")
	merchants_store.add_item(I_HEALTH_POTION.instantiate())
	
func create_collision_shape():
	# If there's an existing collision shape, free it first
	if collision_shape_2d:
		collision_shape_2d.queue_free()


func _on_interactable_interact(player):
	buier = player
	merchants_store.visible = true
