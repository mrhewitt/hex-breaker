extends BonusBlock
class_name SplitterBonusBlock

const BOUNCING_BALL = preload("uid://2r1p6a4olwbg")


# mini balls cannot split again
func can_take_hit(body: Node2D) -> bool:
	return super.can_take_hit(body) and !body.is_mini_ball
	
	
# take incoming ball, split it into two, we also remove existing one
func block_hit(body: BouncingBall) -> bool:
	# create 2 new balls, expanding away at 45 deg, make them smaller
	# so we can see its a split off
	new_ball(body, PI/4)
	new_ball(body, -PI/4)
	# free the original ball
	body.queue_free()
	return true


func new_ball( body: BouncingBall, direction_offset: float ) -> void:
	var ball: BouncingBall = BOUNCING_BALL.instantiate()
	ball.is_mini_ball = true
	ball.position = body.position
	for connection in body.all_balls_docked.get_connections():
		ball.all_balls_docked.connect( connection.callable )
	var direction: float = body.velocity.normalized().angle() + direction_offset
	ball.velocity = Vector2.from_angle(direction) * ball.SPEED
	get_parent().add_child.call_deferred(ball)
