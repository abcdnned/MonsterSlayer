extends Spawner

func do_spawn():
	if wave == 1 and get_alive_mob_count("mob") == 0:
		spawn_tracker(GOBLIN, "mob")
		spawn_tracker(GOBLIN_ARCHER, "mob")
		wave += 1
	elif wave <= 3 and get_alive_mob_count("mob") == 0:
		spawn_tracker(GOBLIN, "mob")
		spawn_tracker(GOBLIN, "mob")
		spawn_tracker(GOBLIN_ARCHER, "mob")
		wave += 1
	elif wave <= 5 and get_alive_mob_count("mob") == 0:
		spawn_tracker(GOBLIN, "mob")
		spawn_tracker(GOBLIN, "mob")
		spawn_tracker(GOBLIN_ARCHER, "mob")
		spawn_tracker(GOBLIN_ARCHER, "mob")
		wave += 1
	elif wave <= 6 and get_alive_mob_count("mob") == 0:
		spawn_tracker(GOBLIN, "mob")
		spawn_tracker(GOBLIN, "mob")
		spawn_tracker(GOBLIN_ARCHER, "mob")
		spawn_tracker(GOBLIN_ARCHER, "mob")
		spawn_tracker(GOBLIN_ARCHER, "mob")
		wave += 1
	elif wave <= 7 and get_alive_mob_count("mob") == 0:
		enable = false
		owner.war_eye.visible = false
		owner.level_complete(2)


