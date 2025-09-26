extends Control

const BOUNCING_BALL = preload("res://entities/bouncing_ball.tscn")

@onready var ball: Node2D = $Ball
@onready var launch_timer: Timer = $LaunchTimer

var preparing_to_fire: bool = false
var level_running: bool = false


func _input(event: InputEvent) -> void:
	if !level_running:
		if event is InputEventMouseButton:
			if event.is_action_pressed("ui_touch"):
				preparing_to_fire = true
				ball.show_launch_line_to( get_global_mouse_position() )
			else:
				release_launch()
		elif event is InputEventMouseMotion and preparing_to_fire:
			ball.show_launch_line_to( get_global_mouse_position() )

	
func release_launch() -> void:
	if preparing_to_fire:
		launch_timer.start()
		ball.launch_line_2d.visible = false
		preparing_to_fire = false
		level_running = true
		BlockSpawner.start_level()
		
		
func _on_launch_timer_timeout() -> void:
	var ball_instance = ball.launch_ball()
	ball_instance.all_balls_docked.connect(level_complete)
	add_child(ball_instance)
	ball_instance.global_position = ball.global_position
	if ball.balls_left == 0:
		launch_timer.stop()
	
	
func level_complete() -> void:
	for wall in get_tree().get_nodes_in_group('wall'):		
		if wall.is_base_wall:
			await move_to_start_point(wall.restart_point).finished			
			break

	# update UI to be ready for user to start new round
	ball.ball_count += 1
	BlockSpawner.next_level()
	level_running = false
	

func move_to_start_point( restart_point: Vector2 ) -> Tween:
	var tween := create_tween()
	tween.tween_property(ball, "global_position", restart_point, 0.5)
	return tween


func _on_base_wall_selected(base_wall: BoundaryWall) -> void:
	move_to_start_point(base_wall.restart_point)
	for wall in get_tree().get_nodes_in_group('wall'):
		if wall != base_wall:
			wall.is_base_wall = false
	
