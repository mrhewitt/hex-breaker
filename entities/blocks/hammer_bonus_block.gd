extends BonusBlock
class_name HammerBonusBlock

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hammer_particles_2d: GPUParticles2D = $HammerParticles2D
@onready var default_scale: Vector2 = scale

var scale_tween: Tween = null

func _ready() -> void:
	scale = Vector2(0.8,0.8)
	
	
func show_hit() -> void:
	super.show_hit()
	if scale_tween == null or !scale_tween.is_valid():
		scale_tween = create_tween()
		scale_tween.tween_property(self, 'scale', Vector2.ONE, 0.05)	
		scale_tween.tween_property(self, 'scale', default_scale, 0.05)	


func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	hammer_particles_2d.emitting = true
	animation_player.play()
