extends CharacterBody2D
class_name BouncingBall

## emitted when ball hits a non-base wall
signal wall_contact( Vector2 )

## emitted when last ball in the air has docked with base ball marker
## i.e. it signifies the round is over
signal all_balls_docked

const SPEED: float = 600

@export var has_bounce_shield: bool = false:
	set(shield):
		has_bounce_shield = shield
		queue_redraw()
		
@onready var sprite_2d: Sprite2D = $Sprite2D
	
var base_move_tween: Tween = null
var is_stopped: bool = false


func _draw() -> void:
	if has_bounce_shield:
		sprite_2d.modulate = Color.YELLOW 
		draw_arc(
			Vector2.ZERO,		# center of origin
			8+2,	
			0,					# 0 - 360 deg => full cricle	
			360,
			50,					# 50 points to look nice
			Color.GREEN_YELLOW,	
			2,				
			true
		)
	else:
		sprite_2d.modulate = Color.WHITE
		

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
	# turn off collisions with blocks so we can drop to base wall
	set_collision_mask_value(2,false)
	
