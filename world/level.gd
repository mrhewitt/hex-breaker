extends Control

const BOUNCING_BALL = preload("res://entities/bouncing_ball.tscn")

# state of input to ball targeting arrow, 
#	blocked - cannot use mouse to aim or fire ball
#	waiting - ready for user input
#	aiming	- currenly dragging target line, mouse up will fire and start level
enum BallAimState { BLOCKED, WAITING, PREPARING_TO_AIM, AIMING }

@onready var ball: Node2D = $Ball
@onready var launch_timer: Timer = $LaunchTimer
@onready var bottom_wall: BoundaryWall = $BottomWall

# start blocked so opening aimations/hex blocks can be done
var targeting_state: BallAimState = BallAimState.BLOCKED
var start_drag_position: Vector2


func _ready() -> void:
	var center_x = get_viewport_rect().size.x/2
	ball.global_position = Vector2(center_x,bottom_wall.global_position.y - ball.get_ball_radius() - 6)
	BlockSpawner.block_drop_complete.connect( _on_ready_to_aim )
	

func _input(event: InputEvent) -> void:
	if targeting_state != BallAimState.BLOCKED:
		if event is InputEventMouseButton:
			if event.is_action_pressed("ui_touch"):
				targeting_state = BallAimState.PREPARING_TO_AIM
				start_drag_position = get_global_mouse_position()
			else:
				# if user released mouse button without much movement revent
				# back to waiting state, otherwise release the ball if aiming 
				if targeting_state == BallAimState.PREPARING_TO_AIM:
					targeting_state = BallAimState.WAITING
				else:
					release_launch()
		elif event is InputEventMouseMotion:
			if targeting_state == BallAimState.PREPARING_TO_AIM:
				if Vector2(start_drag_position-get_global_mouse_position()).length() > 5:
					ball.show_launch_line_to( get_global_mouse_position() )
					# clear target points on other walls, we cannot change now we started aiming
					BoundaryWall.clear_all_start_points()
					targeting_state = BallAimState.AIMING
			elif targeting_state == BallAimState.AIMING: 
				ball.show_launch_line_to( get_global_mouse_position() )


func release_launch() -> void:
	if targeting_state == BallAimState.AIMING:
		launch_timer.start()
		ball.launch_line_2d.visible = false
		targeting_state = BallAimState.BLOCKED
		BlockSpawner.start_level()
		
		
func _on_launch_timer_timeout() -> void:
	var ball_instance = ball.launch_ball()
	ball_instance.all_balls_docked.connect(level_complete)
	add_child(ball_instance)
	ball_instance.global_position = ball.global_position
	if ball.balls_left == 0:
		launch_timer.stop()
	
	
func level_complete() -> void:
#	for wall in get_tree().get_nodes_in_group(Groups.WALL):		
#		if wall.is_base_wall:
	#		await move_to_start_point(wall.restart_point).finished			
#			break
	await move_to_start_point( BoundaryWall.get_base_wall().restart_point ).finished	
	# update UI to be ready for user to start new round
	ball.ball_count += 1
	BlockSpawner.next_level()


func move_to_start_point( restart_point: Vector2 ) -> Tween:
	var tween := create_tween()
	tween.tween_property(ball, "global_position", restart_point, 0.25)
	return tween


func _on_ready_to_aim() -> void:
	targeting_state = BallAimState.WAITING


func _on_base_wall_selected(base_wall: BoundaryWall) -> void:
	move_to_start_point(base_wall.restart_point)
	# hide aiming line so we can start from new point
	targeting_state == BallAimState.WAITING
	ball.launch_line_2d.visible = false
	
	
