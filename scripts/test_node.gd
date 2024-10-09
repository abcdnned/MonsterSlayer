extends Node

const ROAD = 0
const TREE_WALL = 1

func generate_map(width, height, min_chamber_size, max_chamber_size, number_of_chambers):
	var map = []
	for i in range(height):
		var row = []
		for j in range(width):
			row.append(TREE_WALL)
		map.append(row)

	var chamber_centers = []

	for i in range(number_of_chambers):
		var chamber_width = randi() % (max_chamber_size - min_chamber_size + 1) + min_chamber_size
		var chamber_height = randi() % (max_chamber_size - min_chamber_size + 1) + min_chamber_size
		var x = randi() % (width - chamber_width)
		var y = randi() % (height - chamber_height)

		place_chamber(map, x, y, chamber_width, chamber_height)
		var center_x = x + chamber_width / 2
		var center_y = y + chamber_height / 2
		chamber_centers.append(Vector2(center_x, center_y))

	connect_chambers(map, chamber_centers)

	return map

func place_chamber(map, x, y, chamber_width, chamber_height):
	for i in range(chamber_height):
		for j in range(chamber_width):
			if x + j >= 0 and x + j < len(map[0]) and y + i >= 0 and y + i < len(map):
				if i == 0 or i == chamber_height - 1 or j == 0 or j == chamber_width - 1:
					map[y + i][x + j] = TREE_WALL
				else:
					map[y + i][x + j] = ROAD

func connect_chambers(map, chamber_centers):
	for i in range(len(chamber_centers) - 1):
		var start = chamber_centers[i]
		var end = chamber_centers[i + 1]

		var cx = int(start.x)
		var cy = int(start.y)

		while cx != int(end.x):
			map[cy][cx] = ROAD
			cx += 1 if end.x > cx else -1

		while cy != int(end.y):
			map[cy][cx] = ROAD
			cy += 1 if end.y > cy else -1


# Example usage
func _ready():
	var game_map = generate_map(20, 20, 3, 3, 3)
	for row in game_map:
		print(row)
