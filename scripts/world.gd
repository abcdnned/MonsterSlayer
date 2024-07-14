# 5.2 target
# TODO carry key goblin
# TODO Starter Plain spawner
# TODO arean mode?


# Backlogs
# design monster tire
# mob wolf
# mob spear goblin
# 6 weapon design
# Sheild charge
# goblin bomber
# notification when target spotted
# switch weapon
# Goblin Flag generator
# no cycle tree
# war fog
# light
# multi items
# weapon tire
# rush gallary
# burnable wooden locked door
# key merchants boss
# goblin summoner
# treasure goblin sneaker
# white eye attack, purple eye attack
# lootable precise collision
# just pressed attack

extends Node2D

@onready var player = null
@onready var tile_map = $TileMap
@onready var kill = $UI/Kill
@onready var coins = $UI/Coins
@onready var winning_scene = $UI/WinningScene
@onready var hearts = $UI/Life/Hearts
@onready var max_hearts = $UI/Life/MaxHearts
@onready var spawner = $GoblinArmy1Spawner
@onready var lose_scene = $UI/LoseScene
@onready var winning_sound = $WinningSound
@onready var map = $UI/Map
@onready var war_eye = $UI/WarEye
const PLAYER = preload("res://scenes/player.tscn")
const PLAYER_SPEAR = preload("res://scenes/player_spear.tscn")
const PLAYER_HAMMER = preload("res://scenes/player_hammer.tscn")
const GOBLIN_ARMY_TOP_LEFT = Vector2(-3600, -4000)
const GOBLIN_ARMY_BOTTOM_RIGHT = Vector2(3600, -11000)
var money: int = 0
var kill_count = 0

# Called when the node enters the scene tree for the first time.
#   1
# 4   2
#   3
func _ready():
	randomize()
	load_player(PLAYER_HAMMER, Vector2(0, 0))
	var route := {}
	map.create_boime(-10, 10, -10, 10, 4, 4, 0, route)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _on_player_hero_death():
	lose_scene.visible = true

func _on_mob_death(node):
	kill_count += 1
	kill.text = "KILL " + str(kill_count)
	if node.name == "GoblinWarrior":
		_win()

func _win():
	winning_scene.visible = true
	spawner.enable = false
	winning_sound.play()
	var mobs = get_tree().get_nodes_in_group("mob")
	for mob in mobs:
		mob.add_to_group("lose")


func _on_spawner_starter_timeout():
	spawner.enable = true

func load_player(player_type, position):
	if player != null:
		player.queue_free()
		player = null
	player = player_type.instantiate()
	player.global_position = position
	add_child(player)
	player.owner = self
	player.health_change.connect(hearts._on_player_health_change)
	player.max_health_change.connect(max_hearts._on_player_max_health_change)
	player.hero_death.connect(_on_player_hero_death)
	player.map_pos_change.connect(map._on_player_map_pos_change)
	player.map_pos_change.connect(_on_player_map_pos_change)
	player._ready()

func _on_player_map_pos_change(x, y):
	var p = tile_map.local_to_map(tile_map.to_local(Vector2(x, y)))
	var i = self.map.tile_to_cord[Vector2(p.x, p.y)]
	if i and map.war_eye[i.x][i.y] > 0:
		war_eye.visible = true
	else:
		war_eye.visible = false
	if i and map.war_eye[i.x][i.y] == 1:
		spawner.enable = true
	else:
		spawner.enable = false
	#print(Vector2(x, y)) # TODO get pos
		
func get_money(m):
	money += m
	coins.text = "Coins: " + str(money)

func spawn(type, top_left, bottom_right):
	var spawn_position = map.get_spawn_position(top_left, bottom_right)
	var thing = type.instantiate()
	thing.position = spawn_position
	add_child(thing)
	return thing

	
