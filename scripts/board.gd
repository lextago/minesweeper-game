extends TileMapLayer

const WIDTH := 30
const HEIGHT := 16
const NUM_MINES := 99

# -1 : empty
# 0 : mine
# 1-8 : num mines
var tiles : Array[int]
var first_move = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_up_board()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("reveal"):
		var cursor_coords : Vector2i = local_to_map(get_local_mouse_position())
		
		if(first_move):
			var curr_tile_val = set_tile(cursor_coords)
			while not curr_tile_val == -1:
				tiles.shuffle()
				curr_tile_val = set_tile(cursor_coords)
			first_move = false
		reveal_tile(cursor_coords)
		
		#print(tiles[get_tile_index(cursor_coords)] == 0)
		#print(get_surrounding_tiles(cursor_coords))

	if event.is_action_pressed("flag"):
		var cursor_coords : Vector2i = local_to_map(get_local_mouse_position())
		set_cell(cursor_coords, 0, Vector2i(1,0))
	if event.is_action_pressed("reveal all"):
		var numMines = 0
		for y in HEIGHT:
			for x in WIDTH:
				reveal_tile(Vector2i(x,y))
				
				if tiles[get_tile_index(Vector2i(x,y))] == 0:
					numMines += 1
		if numMines == NUM_MINES:
			print(true)
		else:
			print("expected : " + str(NUM_MINES))
			print("actual : " + str(numMines))
		
	if event.is_action_pressed("reset"):
		tiles.clear()
		set_up_board()
		first_move = true


func set_up_board()->void:
	for y in HEIGHT:
		for x in WIDTH:
			set_cell(Vector2i(x,y), 0, Vector2i(0,0))
			tiles.append(-1)
	for i in range(NUM_MINES):
		tiles[i] = 0
	tiles.shuffle()


func reveal_tile(tile_coords : Vector2i)->void:
	var curr_tile_val = set_tile(tile_coords)
	
	match curr_tile_val:
		-1: 
			set_cell(tile_coords, 0, Vector2i(3,0))
			reveal_surrounding_tiles(tile_coords)
		0: set_cell(tile_coords, 0, Vector2i(0,3))
		1: set_cell(tile_coords, 0, Vector2i(0,1))
		2: set_cell(tile_coords, 0, Vector2i(1,1))
		3: set_cell(tile_coords, 0, Vector2i(2,1))
		4: set_cell(tile_coords, 0, Vector2i(3,1))
		5: set_cell(tile_coords, 0, Vector2i(0,2))
		6: set_cell(tile_coords, 0, Vector2i(1,2))
		7: set_cell(tile_coords, 0, Vector2i(2,2))
		8: set_cell(tile_coords, 0, Vector2i(3,2))


func reveal_surrounding_tiles(tile_coords : Vector2i) -> void:
	for i in get_surrounding_tiles(tile_coords):
		var curr_atlas_coords = get_cell_atlas_coords(i)
		if curr_atlas_coords == Vector2i(0,0):
			reveal_tile(i)


func get_surrounding_tiles(tile_coords : Vector2i) -> Array[Vector2i]:
	var surrounding_tiles : Array[Vector2i]
	for y in range(-1,2):
		for x in range(-1,2):
			var curr_coords = Vector2i(tile_coords.x + x, tile_coords.y + y)
			if not tile_coords == curr_coords:
				var tile_index = get_tile_index(curr_coords)
				if tile_index > -1:
					surrounding_tiles.append(curr_coords)
	return surrounding_tiles


func set_tile(tile_coords : Vector2i) -> int:
	var surrounding_tiles = get_surrounding_tiles(tile_coords)
	var curr_tile_val = tiles[get_tile_index(tile_coords)]
	var numMines = 0
	
	for i in surrounding_tiles:
		if tiles[get_tile_index(i)] == 0:
			numMines += 1

	if numMines > 0 and not curr_tile_val == 0:
		tiles[get_tile_index(tile_coords)] = numMines
		return numMines
	else:
		return curr_tile_val


func get_tile_index(tile_coords : Vector2i)->int:
	if tile_coords.x < WIDTH and tile_coords.y < HEIGHT and tile_coords.x >= 0 and tile_coords.y >= 0:
		return tile_coords.y * WIDTH + tile_coords.x
	else:
		return -1
