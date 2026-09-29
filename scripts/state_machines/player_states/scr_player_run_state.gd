extends PlayerState

func enter_state():
	player.num_jumps = 0


func exit_state():
	pass

func update(delta:float):
	player.animation_player.play("run")
	if(player.is_on_floor()):
		player.coyote_timer = player.COYOTE_TIME;
	else:
		player.coyote_timer = max(player.coyote_timer - delta, 0.0)
	
func physics_update(delta:float):
	#Apply Move
	GroundMove(delta)
		
	if not player.is_on_floor():
		ApplyGravity(Move.FALL_GRAVITY_MULT, delta)
