extends Node

## fired when level counter is bumped up to indicate we moved to a new level
signal level_updated(level)
signal level_started

## emitted when all block animations are start of new level are done, and user
## can now being to aim his next shot
signal block_drop_complete

## emitted when blocks hit bottom of screen and its game over
signal blocks_reached_bottom

# all levels up till this will allocate number of hits as
# level number, greater will allocate level number of 2xlevel
const MAX_LEVEL_LINEAR_HITS = 5

# max number of blocks to put horicontally, odd rows will have 1 less
# as the hexes slot into the spaces of blocks on even rows
const MAX_BLOCKS_ACROSS = 8 

const HEX_RADIUS = 50
const MAX_ROWS = 12

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
const BALL_BONUS_BLOCK = preload("uid://dctqxoyhgsjqp")
const HAMMER_BLOCK = preload("uid://ddnv4ois0lm0s") 
const SHIELD_BLOCK = preload("uid://bt1xjcar62vle")
const SPLITTER_BONUS_BLOCK = preload("uid://cnq3vgsdhu7ls")
const BONUS_BLOCKS = [	
	BALL_BONUS_BLOCK, HAMMER_BLOCK, SHIELD_BLOCK, SPLITTER_BONUS_BLOCK
]

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
#var y_offset: float = 0
var level_node: Control = null
var top_row:int = MAX_ROWS
# when a block moves below this y position its game over
var death_y: float = 0

func set_level_node(_level_node: Control) -> void:
	level_node = _level_node 
	#y_offset = -level_node.size.y + ROW_SPACING*3
	death_y = level_node.size.y - ROW_SPACING
	
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
	#create_row()


func start_level() -> void:
	level_started.emit()


func create_row() -> void:
	# create an array of open row indexes, each time one is places we take it out
	# that way we never have issue having to loop picking random numbers if a slot is full 
	var total_block_count = MAX_BLOCKS_ACROSS if top_row % 2 == 0 else MAX_BLOCKS_ACROSS - 1
	var available_slots: Array
	for i in range(0,total_block_count):
		available_slots.append(i)

	# work out maximum blocks, if low level then its just one, otherwise
	# it is netweem 1-3
	var block_count = 1 if level < MAX_LEVEL_LINEAR_HITS else randi_range(1,3)
	var move_tween: Tween = create_tween().parallel()
	move_tween.finished.connect( block_drop_complete.emit )
	for i in range(0, block_count):
		var column = available_slots.pick_random()
		available_slots.erase(column)
		
		var block
		if i == block_count+30:
			block = SPLITTER_BONUS_BLOCK.instantiate()
			level_node.add_child(block)
		else:
			block = BLOCK.instantiate()
			level_node.add_child(block)
			block.hits = get_hits_to_allocate()
		block.grid_position = Vector2i(column,top_row)
		# animate blocks appearance so it drops in from above
		var target_y: float = block.position.y
		block.position.y = -HEX_RADIUS
		move_tween.tween_property(block, 'position:y', target_y, randf_range(0.05,0.25))
	

func get_hits_to_allocate() -> int:
	if level <= MAX_LEVEL_LINEAR_HITS:
		return level
	else:
		return [level,level*2].pick_random()


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
		var move_tween = create_tween()
		move_tween.tween_property(block, 'position:y', level_node.get_rect().size.y, 0.4 + randf_range(0.0,0.4))
		move_tween.finished.connect(block.queue_free)
	
	
# move all blocks down 
func move_down() -> void:
	#y_offset += ROW_SPACING
	top_row -= 1 
	
	var move_tween: Tween = null
	var start_delay: float = 0.0
	for block in get_tree().get_nodes_in_group(Groups.BLOCK):
		# animate blocks downward movement, add a slight delay so it looks like thay
		# fall, use row index to determine delay (as blocks may not be in order in
		move_tween = create_tween()
		#var start_delay: float = ((MAX_ROWS-block.grid_position.y) * 0.2) + (0.075 + (block.grid_position.x*0.025))
		move_tween.tween_interval(start_delay)
		start_delay += 0.05
		move_tween.tween_property(block, 'position:y', block.position.y + ROW_SPACING, 0.05)
	
	# attach finsih event to final move tween to create new row once done animating
	# existing rows down, if no existing rows, go direct to create new row
	if move_tween:
		move_tween.finished.connect( block_row_move_complete )
	else:
		create_row()


func block_row_move_complete() -> void:
	# if any blocks moved below death line game over
	# we only do this check after move complete so user can see visually its over
	for block in get_tree().get_nodes_in_group(Groups.BLOCK):
		if block.position.y >= death_y:
			blocks_reached_bottom.emit()
			return
			
	create_row()


func grid_to_pixel( grid_position: Vector2i ) -> Vector2:
	var x:float = sqrt(3) * (grid_position.x + 0.5 * (grid_position.y&1))
	var y:float =  3./2 * grid_position.y
	# scale cartesian coordinates
	x = x * HEX_RADIUS + 58 
	y = ROW_SPACING*2
	return Vector2(x, y)
	

func pointy_hex_to_pixel(hex: Vector2i) -> Vector2:
	# hex to cartesian
	var x:float = (sqrt(3) * hex.x  +  sqrt(3)/2 * hex.y)
	var y:float = (3.0/2.0 * hex.y)
	# scale cartesian coordinates
	x = x * HEX_RADIUS
	y = y * HEX_RADIUS
	return Vector2(x, y)
