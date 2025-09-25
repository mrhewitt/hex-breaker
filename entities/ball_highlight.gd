@tool 
extends Node2D

const STARTING_RADIUS = 16.0
const WIDTH = 2

@export var max_radius: float = 32 
@export var duration: float = 0.75 
@export var color: Color = Color.WHITE

@onready var _radius: float = STARTING_RADIUS
@onready var _color: Color = color


func _ready() -> void:
	var tween := create_tween()
	tween.set_loops().set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self,'_radius',max_radius,0.5)
	tween.parallel().tween_property(self,'_color:a',0,0.5)	
	tween.loop_finished.connect(reset_state)


func _process(_delta: float) -> void:
	queue_redraw()
	
	
func _draw() -> void:
	draw_arc(
		Vector2.ZERO,		# center of origin
		_radius,	
		0,					# 0 - 360 deg => full cricle	
		360,
		50,					# 50 points to look nice
		_color,	
		WIDTH,				
		true
	)
	
	
func reset_state(loop: int) -> void:
	_radius = STARTING_RADIUS
	_color = color
