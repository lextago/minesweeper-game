extends TileMapLayer

const WIDTH := 30
const HEIGHT := 16
const NUM_MINES := 99

# -1 : empty
# 0 : mine
# 1-8 : num mines
var tiles : Array[int]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_up_board()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("reveal"):
		var cursor_coords : Vector2i = local_to_map(get_local_mouse_position())
		reveal_tile(cursor_coords)
	if event.is_action_pressed("reveal all"):
		for y in HEIGHT:
			for x in WIDTH:
				reveal_tile(Vector2i(x,y))
	if event.is_action_pressed("reset"):
		set_up_board()



func set_up_board()->void:
	tiles.clear()
	for y in HEIGHT:
		for x in WIDTH:
			set_cell(Vector2i(x,y), 0, Vector2i(0,0))
			tiles.append(-1)
	for i in range(NUM_MINES):
		tiles[i] = 0
	tiles.shuffle()


func reveal_tile(tile_coords : Vector2i)->void:
	set_tile(tile_coords)
	match tiles[get_tile_index(tile_coords)]:
		-1: set_cell(tile_coords, 0, Vector2i(3,0))
		0: set_cell(tile_coords, 0, Vector2i(0,3))
		1: set_cell(tile_coords, 0, Vector2i(0,1))
		2: set_cell(tile_coords, 0, Vector2i(1,1))
		3: set_cell(tile_coords, 0, Vector2i(2,1))
		4: set_cell(tile_coords, 0, Vector2i(3,1))
		5: set_cell(tile_coords, 0, Vector2i(0,2))
		6: set_cell(tile_coords, 0, Vector2i(1,2))
		7: set_cell(tile_coords, 0, Vector2i(2,2))
		8: set_cell(tile_coords, 0, Vector2i(3,2))


func get_surrounding_mines(tile_coords : Vector2i)->Array[Vector2i]:
	var surrounding_mines : Array[Vector2i]
	for y in range(-1,2):
		for x in range(-1,2):
			var curr_coords := Vector2i(tile_coords.x + x, tile_coords.y + y)
			if not tile_coords == curr_coords:
				var curr_index := get_tile_index(curr_coords)
				if tiles[curr_index] == 0:
					surrounding_mines.append(curr_coords) 
	return surrounding_mines


func set_tile(tile_coords : Vector2i)->void:
	var mines := get_surrounding_mines(tile_coords)
	var curr_tile := get_tile_index(tile_coords)
	
	#checks if tile is not a bomb
	if mines.size() > 0 and not tiles[get_tile_index(tile_coords)] == 0:
		tiles[get_tile_index(tile_coords)] = mines.size()


func get_tile_index(tile_coords : Vector2i)->int:
	if tile_coords.x < WIDTH and tile_coords.y < HEIGHT and tile_coords.x >= 0 and tile_coords.y >= 0:
		return tile_coords.y * WIDTH + tile_coords.x
	else:
		return -1
