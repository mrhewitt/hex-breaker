extends Node2D

const BOUNCING_BALL = preload("res://entities/bouncing_ball.tscn")

## Number of balls that will be emitted in the next round
@export var ball_count: int = 1:
	set(count_in):
		ball_count = count_in
		balls_left = ball_count
		update_ball_counter()

@onready var launch_line_2d: LaunchLine2D = $LaunchLine2D
@onready var total_balls_label: Label = $TotalBallsLabel
@onready var sprite_2d: Sprite2D = $Sprite2D

var target_point: Vector2
var balls_left: int = 1:
	set(count_in):
		balls_left = count_in
		update_ball_counter()
		

func _ready() -> void:
	update_ball_counter()
	
	
func get_ball_radius() -> float:
	return sprite_2d.texture.get_width()/2.0 
	
	
func update_ball_counter() -> void:		
	if total_balls_label != null:
		if balls_left <= 0:
			total_balls_label.text = ''
		else:
			modulate.a = 1
			total_balls_label.text = 'x' + str(balls_left)
		

func show_launch_line_to( point: Vector2 ) -> void:
	target_point = point
	#var end_point := Vector2( point - global_position ).normalized() * 312
	launch_line_2d.start_point = global_position
	launch_line_2d.end_point = target_point #Vector2( point - global_position ).normalized() * 512
	launch_line_2d.visible = true


func launch_ball() -> BouncingBall:
	modulate.a = 0.25
	var ball:BouncingBall = BOUNCING_BALL.instantiate()
	ball.global_position = global_position
	ball.velocity = Vector2( to_global(launch_line_2d.end_point) - global_position ).normalized() * ball.SPEED
	balls_left -= 1
	return ball
