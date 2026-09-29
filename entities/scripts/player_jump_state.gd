extends PlayerState



func enter_state():		
	if player.num_jumps > player.max_jumps:
		return
		
		
	if(player.num_jumps < player.max_jumps - 1):
		player.animation_player.play("jump")
	else:
		player.animation_player.play("flip")
		
	player.velocity.y = 0
	Juice.play_sfx(player.jump_sound)
	jump(player.jump_multiplier)
	player.num_jumps += 1

func exit_state():
	player.jump_multiplier = 1
	state_forced = false

func update(delta:float):	
	player.jump_buffer_timer = max(player.jump_buffer_timer - delta, 0.0)
	
func physics_update(delta:float):
	GroundMove(delta)
		
	if not player.is_on_floor():
		ApplyGravity(Move.RISE_GRAVITY_MULT, delta)


func jump(multipler:float = 1):
	if player.num_jumps >= player.max_jumps: return

	var current_velocity = player.velocity * multipler
	
	player.velocity.y = Move.JUMP_VELOCITY * multipler
	player.velocity.x = abs(current_velocity.x) * player.direction
	player.sprite.scale = Juice.stretch(player.squash_min, player.squash_max)#Squash and ->Stretch
