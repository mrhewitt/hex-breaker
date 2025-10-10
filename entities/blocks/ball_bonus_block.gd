extends BonusBlock
class_name BallBonusBlock

@onready var ball_sprite: Sprite2D = $BallSprite
@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D
@onready var ball_highlight: Node2D = $BallHighlight


func clear_effects() -> void:
	super.clear_effects()
	ball_highlight.visible = false
	

# player gets an extra ball, a once off bonus so destroy block on first contact
func block_hit(_body: BouncingBall) -> bool:
	GameManager.extra_balls += 1
	hide_block()
	# take it out bonus group in case level ends while we are animating
	# we dont want it to fall way whilst particles are going
	remove_from_group(Groups.BONUS_BLOCK)
	ball_sprite.visible = false
	emit_particles.call_deferred()
	return false
	
	
func emit_particles() -> void:
	gpu_particles_2d.emitting = true
	await gpu_particles_2d.finished
	queue_free()
	
