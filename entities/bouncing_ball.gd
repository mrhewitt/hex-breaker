@tool 
extends CharacterBody2D
class_name BouncingBall

## emitted when ball hits a non-base wall
signal wall_contact( Vector2 )

## emitted when last ball in the air has docked with base ball marker
## i.e. it signifies the round is over
signal all_balls_docked

const SPEED: float = 600

@export var shield_color: Color

@export var has_bounce_shield: bool = false:
	set(shield):
		has_bounce_shield = shield
		queue_redraw()
		
@export var is_mini_ball: bool = false:
	set(is_mini):
		is_mini_ball = is_mini
		if is_mini_ball:
			scale = Vector2(0.65,0.65)
		else:			
			scale = Vector2.ONE
			
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var ball_highlight: Node2D = $BallHighlight

var base_move_tween: Tween = null
var is_stopped: bool = false


func _draw() -> void:
	if has_bounce_shield:
		sprite_2d.modulate = shield_color
		#ball_highlight.visible = true
		draw_arc(
			Vector2.ZERO,		# center of origin
			get_ball_radius()+6,	
			0,					# 0 - 360 deg => full cricle	
			360,
			50,					# 50 points to look nice
			shield_color,	
			3,				
			true
		)
	else:
		sprite_2d.modulate = Color.WHITE
	#	ball_highlight.visible = false
		

func _physics_process(delta: float) -> void:
	if !is_stopped:
		var collision = move_and_collide(velocity * delta)
		if collision:
			var target := collision.get_collider()
			velocity = velocity.bounce(collision.get_normal()).normalized() * SPEED  
			if target is WallBody:
				target = target.boundary_wall
				wall_contact.emit(global_position)
				
				var is_first_contact = target.set_contact_point(global_position)
				
				# if it is a base, we stop normal physics and instead just "suck"
				# ball toward to base starting point
				# only do this if we do not have an active shield, which allows
				# us one bonus bounce off base wall
				if target.is_base_wall:
					if !has_bounce_shield:
						is_stopped = true
						is_mini_ball = false	# full size now we are docked
						if !is_first_contact:
							base_move_tween = create_tween()
							base_move_tween.tween_property(self, "global_position", target.restart_point, 0.1)
							# remove ball clone if its not the first one, we want one to remain so we can
							# see visually where next default start point will be
							base_move_tween.finished.connect(docked_with_base_ball)
						else:	
							become_base_ball()
					else:
						has_bounce_shield = false
			elif target.has_method('take_hit'):
				target.take_hit()


func get_ball_radius() -> float:
	return sprite_2d.texture.get_width()/2.0 
	
	
func become_base_ball() -> void:
	var balls_left = get_tree().get_nodes_in_group(Groups.BOUNCING_BALLS).size()
	# we are only ball in air, so mark level as done now we are docked
	if balls_left == 1:
		all_balls_docked.emit()
		
		
func docked_with_base_ball() -> void:
	var balls_left = get_tree().get_nodes_in_group(Groups.BOUNCING_BALLS).size()
	# free instance now it is in base ball
	queue_free()
	# if we only had this ball and the marker ball left, flag round as done
	if balls_left <= 2:
		all_balls_docked.emit()


func drop_to_ground() -> void:
	# mask only walls layer so we do not collide with anything else as we are
	# essentially out of the game
	#set_collision_mask_value(2,false)
	set_collision_mask(4)
	# find vall that is base wall, and determine which direction to move
	var base_wall := BoundaryWall.get_base_wall()
	match base_wall.side:
		BoundaryWall.BoundarySide.LEFT: velocity = Vector2.LEFT
		BoundaryWall.BoundarySide.RIGHT: velocity = Vector2.RIGHT
		BoundaryWall.BoundarySide.TOP: velocity = Vector2.UP
		BoundaryWall.BoundarySide.BOTTOM: velocity = Vector2.DOWN
	velocity *= SPEED
	
