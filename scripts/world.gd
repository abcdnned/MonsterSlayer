# 10 DAYS PLAN Starting Day Oct 9
# 1 Random stage 1 map
# 2 Random stage 1 map
# 3 Random stage 1 map
# 4 Random Tree and Apple
# 5 4 key open gate
# 6 Random monster spawn
# 7 Random monster spawn
# 8 Random monster spawn
# 9 Goblin King's Treasure
# 10 Win and Lose 

# lv2 2 -> lv3 6 -> lv4 12 -> lv5 20 -> lv6 30 -> lv7 42
# Backlogs
# SFX: wolf, boomer
# weapon tire
# treasure goblin sneaker
# item drop
# white eye attack, purple eye attack
# lootable precise collision
# just pressed attack
# adopt hammer and spear
# design monster tire
# pickable change cursor
# spear double stub
# bought floating text
# weapon tier, common, rare, epic, mythical; weapon damage tier: 1 < common < 3 < rare < 5 < epic < 7 < mythical < 9
# weapon skills tier, Novice, Adept, GrandMaster, legend
# strength system, support using heavy weapon, increased by potion
# award merchants, king knight, give stage awards, can be purchased by money


extends Node2D

@onready var player = null
@onready var kill = $UI/Kill
@onready var coins = $UI/Coins
@onready var winning_scene = $UI/WinningScene
@onready var hearts = $UI/Life/Hearts
@onready var stamina = $UI/Energy/Stamina
@onready var max_stamina = $UI/Energy/MaxStamina
@onready var max_hearts = $UI/Life/MaxHearts
@onready var lose_scene = $UI/LoseScene
@onready var winning_sound = $WinningSound
@onready var map = $UI/Map
@onready var war_eye = $UI/WarEye
@onready var goblin_army_1_spawner = $LevelSpawner/GoblinArmy1Spawner
@onready var goblin_army_2_spawner = $LevelSpawner/GoblinArmy2Spawner
@onready var quest = $UI/Quest
@onready var merchants = $NPCs/Merchants
@onready var progress_timer = $ProgressTimer
@onready var live_enemy = $UI/LiveEnemy
const I_COIN_SMALL = preload("res://scenes/i_coin_small.tscn")
const I_COIN_MEDIUM = preload("res://scenes/i_coin_medium.tscn")
const PLAYER = preload("res://scenes/player.tscn")
const PLAYER_SPEAR = preload("res://scenes/player_spear.tscn")
const PLAYER_HAMMER = preload("res://scenes/player_hammer.tscn")
var money: int = 0
var kill_count = 0
var progress = 0
@onready var mobs: Node = $Mobs
@onready var items: Node = $Items
@onready var random_boime_spawner: Node = $LevelSpawner/RandomBoimeSpawner

# Called when the node enters the scene tree for the first time.
#   1
# 4   2
#   3
func _ready():
	randomize()
	#load_player(PLAYER, Vector2(0, 0), { "health": 1, "max_health": 10 })
	load_player(PLAYER, Vector2(500, 500))
	var route := {}
	map.create_boime()
	random_boime_spawner.init_random_spawn()
	disable_merchants()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if progress == 3 and live_enemy.get_live_enemy_count() == 0:
		_win()
	
func _on_player_hero_death():
	lose_scene.visible = true

func _on_mob_death(node):
	kill_count += 1
	kill.text = "KILL " + str(kill_count)
	if node.name == "GoblinWarrior":
		var coin_medium = I_COIN_MEDIUM.instantiate()
		coin_medium.position = node.global_position
		add_child(coin_medium)
	else:
		var coin_small = I_COIN_SMALL.instantiate()
		coin_small.position = node.global_position
		add_child(coin_small)

func _win():
	winning_scene.visible = true
	winning_sound.play()
	var mobs = get_tree().get_nodes_in_group("mob")
	for mob in mobs:
		mob.add_to_group("lose")

func load_player(player_type, position, stats = null):
	if player != null:
		player.queue_free()
		player = null
	player = player_type.instantiate()
	player.global_position = position
	add_child(player)
	player.owner = self
	player.health_change.connect(hearts._on_player_health_change)
	player.max_health_change.connect(max_hearts._on_player_max_health_change)
	player.stamina_change.connect(stamina._on_player_stamina_change)
	player.max_stamina_change.connect(max_stamina._on_player_max_stamina_change)
	player.hero_death.connect(_on_player_hero_death)
	player.map_pos_change.connect(map._on_player_map_pos_change)
	player.map_pos_change.connect(_on_player_map_pos_change)
	if stats:
		player.health = stats["health"]
		player.max_health = stats["max_health"]
	player.emit_signal("health_change", player.health)
	player.emit_signal("max_health_change", player.max_health)
	player.emit_signal("stamina_change", player.stamina)
	player.emit_signal("max_stamina_change", player.max_stamina)
	
func _on_player_map_pos_change(x, y):
	var p = get_tile_map().local_to_map(get_tile_map().to_local(Vector2(x, y)))
	var i = self.map.tile_to_cord[Vector2(p.x, p.y)]

func get_money(m):
	money += m
	coins.text = "Coins: " + str(money)

func spawn(type, top_left, bottom_right):
	var spawn_position = map.get_spawn_position(top_left, bottom_right)
	var thing = type.instantiate()
	thing.position = spawn_position
	add_child(thing)
	return thing
	
func enable_merchants():
	merchants.visible = true
	merchants.find_child("Interactable").interactable = true

func disable_merchants():
	merchants.visible = false
	merchants.find_child("Interactable").interactable = false

func _on_progress_timer_timeout():
	if progress == 1:
		quest.display_text("Wave 1 : Goblin Archer [lv3]")
		goblin_army_1_spawner._start_sapwner()
	elif progress == 2:
		_win()

func level_complete(level):
	progress += 1
	progress_timer.start()
	
func get_tile_map():
	return find_child("TileMap")
	
@onready var red_key: Control = $UI/RedKey
func get_red_key():
	red_key.visible = true
	
@onready var green_key: Control = $UI/GreenKey
func get_green_key():
	green_key.visible = true

func two_key_obtained():
	return red_key.visible and green_key.visible
