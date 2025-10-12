extends Node2D
class_name LaunchLine2D

		
var end_point: Vector2
		
		
# hide aiming line when we start level (aka balls launched)
func _ready() -> void:
	GameManager.balls_launched.connect(hide)
	GameManager.aim_at.connect(_on_aim)

	
func _on_aim(point: Vector2) -> void:
	visible = true
	end_point = to_local(point)
	queue_redraw()
	
	
func _draw() -> void:
	draw_dashed_line(Vector2.ZERO, end_point, Color.WHITE, 4.0, 12)
