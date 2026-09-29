extends PlayerState

func enter_state():
	player.animation_player.play("fall")

func exit_state():
	if player.current_state == player.idle_state:
		Juice.play_sfx(player.landing_sound)
		player.num_jumps = 0

func update(delta:float):	
	player.jump_buffer_timer = max(player.jump_buffer_timer - delta, 0.0)
	
func physics_update(delta:float):
	GroundMove(delta)
	ApplyGravity(Move.FALL_GRAVITY_MULT, delta)
