extends PlayerState

func enter_state():
	player.animation_player.play("idle")

func exit_state():
	pass

func update(delta:float):	
	if(player.is_on_floor()):
		player.coyote_timer = player.COYOTE_TIME;
	else:
		player.coyote_timer = max(player.coyote_timer - delta, 0.0)
	
func physics_update(delta:float):
	#Apply (lack of) Move
	if(player.direction):
		var acceleration = player.GROUND_ACCELERATION
		player.velocity.x = move_toward(player.velocity.x, player.direction * player.SPEED, acceleration * delta)
	else:
		var friction = player.GROUND_FRICTION
		player.velocity.x = move_toward(player.velocity.x, 0, friction * delta)
