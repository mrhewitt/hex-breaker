extends Control
class_name BoundaryWall

const WALL_WIDTH = 10

enum BoundarySide { TOP, BOTTOM, LEFT, RIGHT }

## True if this wall acts as launching and landing point for balls
@export var is_base_wall: bool = false

## which side of the screen this boundary wall attachs to
@export var side: BoundarySide

@onready var color_rect: ColorRect = $ColorRect
@onready var collision_shape_2d: CollisionShape2D = $WallBody/CollisionShape2D
@onready var wall_body: WallBody = $WallBody

var tween_hit_color: Tween = null
var restart_point: Vector2
var has_restart_point: bool = false


func _ready() -> void:
	set_shape.call_deferred()
	BlockSpawner.level_updated.connect(_on_new_level)
	BlockSpawner.level_started.connect(_on_level_started)


func set_shape() -> void:
	var rect := RectangleShape2D.new()	
	rect.extents = color_rect.size / 2
	collision_shape_2d.shape = rect
	collision_shape_2d.position = color_rect.size / 2


func clear_start_point() -> void:
	has_restart_point = false


func set_contact_point(point_of_contact: Vector2) -> bool:
	if !is_base_wall:
		if tween_hit_color != null:
			tween_hit_color.kill()
			
		tween_hit_color = create_tween()
		tween_hit_color.tween_property(color_rect,"color",color_rect.color,0.1)
		color_rect.color = Color.CRIMSON
		
	if !has_restart_point:
		has_restart_point = true
		restart_point = point_of_contact
		return true			# this is first contact in this ball group
	else:
		return false		# not first contact, restart point already set


# when new level is set, show spawn points so user can select the,
func _on_new_level(_level:int) -> void:
	pass
	
	
# user launched balls to start playing the round
func _on_level_started() -> void:
	clear_start_point()
