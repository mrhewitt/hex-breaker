extends BonusBlock
class_name SplitterBonusBlock

const BOUNCING_BALL = preload("uid://2r1p6a4olwbg")


# take incoming ball, split it into two, we also remove existing one
func block_hit(body: BouncingBall) -> bool:
	# mini balls cannot split again
	if !body.is_mini_ball:
		# create 2 new balls, expanding away at 45 deg, make them smaller
		# so we can see its a split off
		new_ball(body, PI/4)
		new_ball(body, -PI/4)
		# free the original ball
		body.queue_free()
		return true
	else:
		return false

func new_ball( body: BouncingBall, direction_offset: float ) -> void:
	var ball: BouncingBall = BOUNCING_BALL.instantiate()
	ball.is_mini_ball = true
	ball.position = body.position
	var direction: float = body.velocity.normalized().angle() + direction_offset
	ball.velocity = Vector2.from_angle(direction) * ball.SPEED
	get_parent().add_child(ball)
