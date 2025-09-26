extends Node

signal level_updated(level)
signal level_started

const SCALE = 1
const HEX_WIDTH = 100*SCALE
const HEX_HEIGHT = 85*SCALE
const HEX_RADIUS = 50

const ODDR_DIRECTION_DIFFERENCES = [
   # even rows 
	[[+1,  0], [ 0, -1], [-1, -1], 
	 [-1,  0], [-1, +1], [ 0, +1]],
   # odd rows 
	[[+1,  0], [+1, -1], [ 0, -1], 
	 [-1,  0], [ 0, +1], [+1, +1]],
]

# spacing between each "row" of hexs, as they interlock the spacing
# between centers is a fraction of actual hex radius  
const ROW_SPACING: float = (3./2)*HEX_RADIUS

const BLOCK = preload("uid://ddqy4gf7na4l2")
const HAMMER_BLOCK = preload("uid://ddnv4ois0lm0s")

# which type of row is at the top:
# ODD_R - full row of hexes, odd numbered rows are pushed to right (except it our implementation
#				it is also cut one block short to look good
# EVEN_R -  shorter "indented" row is at top, so in hex math even numbered rows are pushed
#				to right, but are also one shorter to look good
# we toggle between odd and even R as we push rows down, as this top row sometimes full
# row, then shorter row, then full row etc		
enum RowMode {ODD_R, EVEN_R}

var level: int = 1:
	set(level_in):
		level = level_in
		level_updated.emit(level)


# we start in odd mode, top row is full row and odd number rows as indented shorter
var row_mode: RowMode = RowMode.ODD_R
var y_offset: float = 0
var level_node: Control = null
var top_row:int = 12


func set_level_node(_level_node: Control) -> void:
	level_node = _level_node 
	y_offset = -level_node.size.y + ROW_SPACING*3
	
	
# called whne round is over, removes bonus tiles, bumps level down one row
# and adds new tiles to  top
func next_level() -> void:
	# make sure all bouncing balls are cleared, one will be start point, but
	# in case of bugs, just make it clean
	for ball in get_tree().get_nodes_in_group(Groups.BOUNCING_BALLS):
		ball.queue_free()
	level += 1
	init_level()
	
	
func init_level() -> void:
	clear_bonus_tiles()
	move_down()
	create_row(top_row)


func start_level() -> void:
	level_started.emit()


func create_row(row: int) -> void:
	var block_count = 8 if row % 2 == 0 else 7
	for column in range(0,block_count):
		var block:Block
		if column == 3:
			block = HAMMER_BLOCK.instantiate()
		else:
			block = BLOCK.instantiate()
		level_node.add_child(block)
		block.grid_position = Vector2i(column,row)
		#block.scale = Vector2(SCALE,SCALE)
		if column != 3:
			block.hits = randi_range(1,5)
	

# return all regular blocks that are nieghbours to the given grid location
func get_neighbours( grid_position: Vector2i ) -> Array[Block]:
	var offset_coords: Array[Vector2i]
	
	# iterate over all 6 possible nieghbours and use direction lookup table to
	# compute actual co-ords of neighbour on that side of the hex
	for neighbour in range(0,6):
		var parity = grid_position.y & 1
		var diff = ODDR_DIRECTION_DIFFERENCES[parity][neighbour]
		offset_coords.append( Vector2i(grid_position.x + diff[0], grid_position.y + diff[1]) )

	# now we know what co-ords are neighbours, iterate over blocks, build and return
	# list of blocks at that location
	var blocks: Array[Block]
	for block in get_tree().get_nodes_in_group(Groups.BLOCK):
		if offset_coords.has( block.grid_position ):
			blocks.append(block)
	return blocks
	
	
func clear_bonus_tiles() -> void:
	for block in get_tree().get_nodes_in_group(Groups.BONUS_BLOCK):
		block.queue_free()
	
	
# move all blocks down 
func move_down() -> void:
	top_row -= 1 
	y_offset += ROW_SPACING
	for block in get_tree().get_nodes_in_group(Groups.BLOCK):
		block.position.y += ROW_SPACING


func grid_to_pixel( grid_position: Vector2i ) -> Vector2:
	var x:float = sqrt(3) * (grid_position.x + 0.5 * (grid_position.y&1))
	var y:float =  3./2 * grid_position.y
	# scale cartesian coordinates
	x = x * HEX_RADIUS + 58 
	y = y * HEX_RADIUS + y_offset
	return Vector2(x, y)
	

func pointy_hex_to_pixel(hex: Vector2i) -> Vector2:
	# hex to cartesian
	var x:float = (sqrt(3) * hex.x  +  sqrt(3)/2 * hex.y)
	var y:float = (3.0/2.0 * hex.y)
	# scale cartesian coordinates
	x = x * HEX_RADIUS
	y = y * HEX_RADIUS
	return Vector2(x, y)
