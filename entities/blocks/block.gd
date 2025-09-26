extends StaticBody2D
class_name Block

@export var hits: int = 1:
	set(hits_in):
		hits = max(0,hits_in)
		if hits > 0:
			if hit_count_label:
				hit_count_label.text = str(hits_in)
		else:
			hit_count_label.visible = false
			
@export var grid_position: Vector2i:
	set(pos):
		grid_position = pos
		position = BlockSpawner.grid_to_pixel(grid_position)

@onready var hit_count_label: Label = %HitCountLabel
@onready var burst_particles_2d: GPUParticles2D = $BurstParticles2D
@onready var collision_polygon_2d: CollisionPolygon2D = $CollisionPolygon2D
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func take_hit( damage:int = 1 ) -> void:
	hits -= damage
	if hits <= 0:
		# dead, hide physical body and show explosion particles
		collision_polygon_2d.disabled = true
		sprite_2d.visible = false
		burst_particles_2d.emitting = true
	else:
		animation_player.play("hit_flash")
		
# we show these particles when block is burst, so free when done
func _on_burst_particles_2d_finished() -> void:
	queue_free()
