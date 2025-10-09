extends Area2D
class_name BonusBlock
			
@export var grid_position: Vector2i:
	set(pos):
		position = BlockSpawner.grid_to_pixel(pos)

@onready var outline_sprite: Sprite2D = $OutlineSprite
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_polygon_2d: CollisionPolygon2D = $CollisionPolygon2D

var hit_list:Array = []
 

# called when a ball hits bonus block, override and do custom processing here
# return true if hit outline must be shown, false otherwise
func block_hit(_body: BouncingBall) -> bool:
	return true


func clear_effects() -> void:
	outline_sprite.visible = false


# hide visible portions of this block, we do not hide entire bonus scene
# as inherited scenes may be using this time to play other visual effects
func hide_block() -> void:
	clear_effects()
	sprite_2d.visible = false
	disable_collisions()


func disable_collisions() -> void:
	collision_polygon_2d.set_deferred('disabled', true)
	

func _on_body_entered(body: Node2D) -> void:
	if body is BouncingBall:
		# check the hitlist, if this body already hit us, but has not yet left,
		# i.e. it is pasing through or bouncing back do not take action, as we 
		# do not want to multiply reward or ui effects
		if !hit_list.has(body): 
			hit_list.append(body)
			if block_hit(body):
				show_hit()
			


func _on_body_exited(body: Node2D) -> void:
	# a body left , so remove it from hit list, as bonus blocks are allowed to be
	# hit again, if a specific bonus is one hit per ball this must be implemented
	# specifically by the bonus override
	hit_list.erase(body) 


func show_hit() -> void:
	outline_sprite.show_outline()
