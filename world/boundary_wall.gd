extends Control
class_name BoundaryWall

signal base_wall_selected(wall)

const WALL_WIDTH = 10
const RESTART_POINT = preload("uid://ckvd7lm26dhna")

enum BoundarySide { TOP, BOTTOM, LEFT, RIGHT }

## True if this wall acts as launching and landing point for balls
@export var is_base_wall: bool = false:
	set(base_wall):
		is_base_wall = base_wall
		if base_wall:
			hide_restart_point()
		else:
			show_restart_point()

## which side of the screen this boundary wall attachs to
@export var side: BoundarySide

## color flash for wall when it gets hit
@export var hit_color: Color

@onready var color_rect: ColorRect = $ColorRect
@onready var collision_shape_2d: CollisionShape2D = $WallBody/CollisionShape2D
@onready var wall_body: WallBody = $WallBody
@onready var default_color: Color = color_rect.color

var tween_hit_color: Tween = null
var restart_point: Vector2
var has_restart_point: bool = false
var restart_point_instance: RestartPoint = null


func _ready() -> void:
	set_shape.call_deferred()
	BlockSpawner.level_updated.connect(_on_new_level)
	BlockSpawner.level_started.connect(_on_level_started)


func set_shape() -> void:
	var rect := RectangleShape2D.new()	
	rect.extents = color_rect.size / 2
	collision_shape_2d.shape = rect
	collision_shape_2d.position = color_rect.size / 2


# removes restart point completely, as opposed to hide_restart_point (which it calls)
# that simply removes the visual but keeps tracking where the point is so it can be
# restored again
func clear_start_point() -> void:
	has_restart_point = false
	hide_restart_point()


func set_contact_point(point_of_contact: Vector2) -> bool:
	if !is_base_wall:
		if tween_hit_color != null:
			tween_hit_color.kill()
			
		tween_hit_color = create_tween()
		tween_hit_color.tween_property(color_rect,"color",default_color,0.1)
		color_rect.color = hit_color
		
	if !has_restart_point:
		has_restart_point = true
		restart_point = point_of_contact
		return true			# this is first contact in this ball group
	else:
		return false		# not first contact, restart point already set
		
		
func show_restart_point() -> void:
	if !is_base_wall and has_restart_point:
		restart_point_instance = RESTART_POINT.instantiate()
		add_child(restart_point_instance)
		restart_point_instance.global_position = restart_point
		restart_point_instance.restart_point_selected.connect(_on_select_restart_point)
	
	
func hide_restart_point() -> void:
	if restart_point_instance != null:
		restart_point_instance.queue_free()
		restart_point_instance = null


# when new level is set, show spawn points so user can select the,
func _on_new_level(_level:int) -> void:
	show_restart_point()
	
	
# user launched balls to start playing the round
func _on_level_started() -> void:
	clear_start_point()
	
	

# handle event when user taps on restart point linked to this wall
# wall becomes new base and we signal parent to move ball onto this spot
func _on_select_restart_point() -> void:
	base_wall_selected.emit(self)
	is_base_wall = true
