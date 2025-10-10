extends Block
class_name HammerBlock

## Minimum amount of damage value hammer can apply
@export_range(1,3,1) var damage_min: int = 1
@export_range(1,3,1) var damage_max: int = 3

@export var has_been_hit: bool = false

@onready var hammer_animation_player: AnimationPlayer = $HammerAnimationPlayer
@onready var hammer_particles_2d: GPUParticles2D = $HammerParticles2D
@onready var default_scale: Vector2 = scale
@onready var outline_sprite: Sprite2D = $OutlineSprite

var scale_tween: Tween = null


func _ready() -> void:
	# scale it down a little so we can make it "hammer" to knock its neighbours
	scale = Vector2(0.8,0.8)
	# remove from blocks group as it s not a block, but a type of bonus
	remove_from_group(Groups.BLOCK)
	hit_count_label.visible = false
	
	
func take_hit( _damage:int = 1 ) -> void:
	has_been_hit = true
	outline_sprite.show_outline()
	if scale_tween == null or !scale_tween.is_valid():
		# expand block to make it look like it "hammers" its neighbours
		# only expand actual sprite as if we exand entire scene it will include
		# the collision shape, and we will get multiple contacts with original
		# ball as scene expands over it
		scale_tween = create_tween()
		scale_tween.tween_property(sprite_2d, 'scale', Vector2(1.2,1.2), 0.05)
		scale_tween.tween_callback(hit_neighbours).set_delay(0.05)	
		scale_tween.tween_property(sprite_2d, 'scale', default_scale, 0.05)
	else:
		hit_neighbours()
		
		
func hit_neighbours() -> void:
	for block in BlockSpawner.get_neighbours(grid_position):
		block.take_hit( 1 ) #randi_range(damage_min,damage_max) )
		

func _on_hammer_animation_player_animation_finished(_anim_name: StringName) -> void:
	hammer_particles_2d.emitting = true
	hammer_animation_player.play()
