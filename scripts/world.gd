# 5.11 target
# TODO level 1 optz
# TODO different level flags
# TODO level 2

# Backlogs
# hit energy
# mouse hover display item info
# weapon tier, common, rare, epic, mythical; weapon damage tier: 1 < common < 3 < rare < 5 < epic < 7 < mythical < 9
# weapon skills tier, Novice, Adept, GrandMaster, legend
# rage system, hit to increase, store to perform special attack of weapon
# weapon durability tier, standard, durable, reinforced, unbreakable
# press S sell item, collect mondy earned form merchants afterwards
# day cycle system, refresh map, supplier
# strength system, support using heavy weapon, increased by potion
# award merchants, king knight, give stage awards, can be purchased by money
# armor system, heavy armor need strenth, could be repair, decrease max stamina
# item ore, used to repair armor
# dynamic supplier system, refresh by bed, i.t a new day
# quest system
# weapon duribilty system, automate reset after seconds, can use item to reset immeditely
# Smith, repair weapon, unlock: one iron
# iron counter UI
# Merchants, unlock: 10 coin
# resource megnets, coin iron
# armor tier iron, stell, silver
# weapon duribility system, if broken reload
# Vit system, increase max health, increased by vit potion
# weapon handy system
# arean mode, choose flag to hit, summon enmeies, get loot, earn money, train skills, beat the boss, lock new arean
# SFX: wolf, boomer
# item slots
# presure plate trape
# notification when target spotted
# switch weapon
# Goblin Flag generator
# no cycle tree
# dash_tired
# dash_angel_limit
# war fog
# light
# multi items， backpack
# weapon tire
# rush gallary
# burnable wooden locked door
# key merchants boss
# goblin summoner
# treasure goblin sneaker
# white eye attack, purple eye attack
# lootable precise collision
# just pressed attack
# stanmine system
# design monster tire
# Sheild charge
# each enemy's ranke, novice, adept, grandMaster, legend
# pickable change cursor
# hitten energy, ultra special attack
# spear double stub
extends Node2D

@onready var player = null
@onready var tile_map = $TileMap
@onready var kill = $UI/Kill
@onready var coins = $UI/Coins
@onready var winning_scene = $UI/WinningScene
@onready var hearts = $UI/Life/Hearts
@onready var max_hearts = $UI/Life/MaxHearts
@onready var lose_scene = $UI/LoseScene
@onready var winning_sound = $WinningSound
@onready var map = $UI/Map
@onready var war_eye = $UI/WarEye
@onready var goblin_army_1_spawner = $LevelSpawner/GoblinArmy1Spawner
const I_COIN_SMALL = preload("res://scenes/i_coin_small.tscn")
const I_COIN_MEDIUM = preload("res://scenes/i_coin_medium.tscn")
const PLAYER = preload("res://scenes/player.tscn")
const PLAYER_SPEAR = preload("res://scenes/player_spear.tscn")
const PLAYER_HAMMER = preload("res://scenes/player_hammer.tscn")
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
	player.hero_death.connect(_on_player_hero_death)
	player.map_pos_change.connect(map._on_player_map_pos_change)
	player.map_pos_change.connect(_on_player_map_pos_change)
	if stats:
		player.health = stats["health"]
		player.max_health = stats["max_health"]
		player.emit_signal("health_change", player.health)
		player.emit_signal("max_health_change", player.max_health)

func _on_player_map_pos_change(x, y):
	var p = tile_map.local_to_map(tile_map.to_local(Vector2(x, y)))
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

func _on_goblin_army_1_spawner_level_1_finish():
	print("level 1 finish")
	_win()
	
