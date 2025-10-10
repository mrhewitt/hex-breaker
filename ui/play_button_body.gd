extends CharacterBody2D

const SPEED = 200.0

## emitted when play button has been pressed, but after particle animation is done
signal play_started

## emitted when play sequence is started, so moment play button is hit
signal play_pressed

@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D
@onready var play_button: Button = $PlayButton


func _ready() -> void:
	velocity = Vector2.from_angle( randf_range(0,TAU) ).normalized() * SPEED


func reset() -> void:
	play_button.visible = true
	gpu_particles_2d.emitting = false


func _physics_process(delta: float) -> void:
	var collision = move_and_collide(velocity * delta)
	if collision:
		velocity = velocity.bounce(collision.get_normal()).normalized() * SPEED  


func _on_gpu_particles_2d_finished() -> void:
	play_started.emit()


func _on_pressed() -> void:
	SfxPlayer.play('start_click')
	play_pressed.emit()
	play_button.visible = false
	gpu_particles_2d.emitting = true
